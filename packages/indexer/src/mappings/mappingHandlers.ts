
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
  // Place your code logic here
}
