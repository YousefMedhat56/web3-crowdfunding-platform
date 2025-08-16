
import { Campaign, Contribution, Refund, Withdrawal } from "../types"
import { CampaignCreatedLog, ContributionReceivedLog, FundsWithdrawnLog, RefundIssuedLog, } from "../types/abi-interfaces/CrowdFundingAbi";
import assert from "assert";



function generateId(txHash: string, logIndex: number): string {
  return `${txHash}-${logIndex}`
}
export async function handleCampaignCreated(log: CampaignCreatedLog): Promise<void> {
  logger.info(`New CampaignCreated Event at block ${log.blockNumber}`);

  assert(log.args, "No log.args");

  const { campaign_id, owner, name, description, goal, deadline, } = log.args
  const campaignId = campaign_id.toString();

  const existing = await Campaign.get(campaignId);
  if (existing) {
    logger.warn(`Campaign ${campaignId} already exists, skipping update`);
    return;
  }

  const campaign = Campaign.create({
    id: campaignId,
    owner,
    name,
    description,
    raised: BigInt(0),
    goal: BigInt(goal.toString()),
    deadline: BigInt(deadline.toString()),
    isWithdrawn: false,
    contributorAddresses: [],
    createdAtBlock: BigInt(log.blockNumber),
    createdAtTimestamp: BigInt(log.block.timestamp),
  });

  await campaign.save();
}

export async function handleContributionReceived(log: ContributionReceivedLog): Promise<void> {

  logger.info(`New ContributionReceived Event at block ${log.blockNumber}`);

  assert(log.args, "No log.args");

  const contributionId = generateId(log.transactionHash, log.logIndex);
  const { campaign_id, contributor, amount } = log.args

  // check if the contribution exists
  const existing = await Contribution.get(contributionId);
  if (existing) {
    logger.warn(`Contribution ${contributionId} already exists, skipping update`);
    return;
  }

  // check if the campagin exists
  const campaignId = campaign_id.toString();
  const campaign = await Campaign.get(campaignId);
  if (!campaign) {
    logger.error(`Campaign ${campaignId} not found for Contribution`);
    return;
  }

  const contribution = Contribution.create({
    id: contributionId,
    campaignId,
    contributor,
    amount: BigInt(amount.toString()),
    refunded: false,
    timestamp: BigInt(log.block.timestamp),
    blockNumber: BigInt(log.blockNumber),
    logIndex: log.logIndex,
    txHash: log.transactionHash,

  });

  await contribution.save();


  // Update Campaign
  campaign.raised = (campaign.raised || BigInt(0)) + BigInt(amount.toString());
  if (!campaign.contributorAddresses!.includes(contributor.toString())) {
    campaign.contributorAddresses!.push(contributor.toString());
  }
  await campaign.save();
}

export async function handleFundsWithdrawn(log: FundsWithdrawnLog): Promise<void> {
  logger.info(`New FundsWithdrawn Event at block ${log.blockNumber}`);

  assert(log.args, "No log.args");

  const withdrawlId = generateId(log.transactionHash, log.logIndex);
  const { campaign_id, amount } = log.args

  // check if the withdrawl exists
  const existing = await Withdrawal.get(withdrawlId);
  if (existing) {
    logger.warn(`Withdrawal ${withdrawlId} already exists, skipping update`);
    return;
  }

  // check if the campaign exists
  const campaignId = campaign_id.toString();
  const campaign = await Campaign.get(campaignId);
  if (!campaign) {
    logger.error(`Campaign ${campaignId} not found for Withdrawl`);
    return;
  }

  const withdrawl = Withdrawal.create({
    id: withdrawlId,
    campaignId,
    amount: BigInt(amount.toString()),
    timestamp: BigInt(log.block.timestamp),
    blockNumber: BigInt(log.blockNumber),
    logIndex: log.logIndex,
    txHash: log.transactionHash,
  });

  await withdrawl.save();

  campaign.isWithdrawn = true;
  await campaign.save();
}

export async function handleRefundIssued(log: RefundIssuedLog): Promise<void> {
  logger.info(`New RefundIssued Event at block ${log.blockNumber}`);

  assert(log.args, "No log.args");

  const refundId = generateId(log.transactionHash, log.logIndex);
  const { campaign_id, contributor, amount } = log.args

  // check if the refund exists
  const existing = await Refund.get(refundId);
  if (existing) {
    logger.warn(`Refund ${refundId} already exists, skipping update`);
    return;
  }

  // check if the campaign exists
  const campaignId = campaign_id.toString();
  const campaign = await Campaign.get(campaignId);

  if (!campaign) {
    logger.error(`Campaign ${campaignId} not found for Refund`);
    return;
  }

  // check if the contributions exists
  const contributions = await Contribution.getByFields(
    [
      ["campaignId", "=", campaignId],
      ["contributor", "=", contributor],
    ],
    { limit: 100 }
  );

  if (!contributions || contributions.length == 0) {

    logger.error(`No contributions found for campaign ${campaignId} and contributor ${contributor}`);
    return;

  }


  const refund = Refund.create({
    id: refundId,
    campaignId,
    contributor,
    amount: BigInt(amount.toString()),
    timestamp: BigInt(log.block.timestamp),
    blockNumber: BigInt(log.blockNumber),
    logIndex: log.logIndex,
    txHash: log.transactionHash,
  });

  await refund.save();

  // Update Campaign.raised
  campaign.raised = (campaign.raised || BigInt(0)) - BigInt(amount.toString());

  // Update Campaign.contributorAddresses
  campaign.contributorAddresses = campaign.contributorAddresses!.filter((address) => address !== contributor.toString());

  await campaign.save();


  // Update Contribution.refunded
  for (const contribution of contributions) {
    contribution.refunded = true;
    await contribution.save();
  }

}
