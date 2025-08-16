
import { Campaign, Contribution, Refund, Withdrawal } from "../types"
import { CampaignCreatedLog, ContributionReceivedLog, FundsWithdrawnLog, RefundIssuedLog, } from "../types/abi-interfaces/CrowdFundingAbi";
import assert from "assert";



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
  // Place your code logic here
}

export async function handleFundsWithdrawn(log: FundsWithdrawnLog): Promise<void> {
  // Place your code logic here
}

export async function handleRefundIssued(log: RefundIssuedLog): Promise<void> {
  // Place your code logic here
}
