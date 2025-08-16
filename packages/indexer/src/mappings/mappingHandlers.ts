import { CampaignCreatedLog, ContributionReceivedLog, FundsWithdrawnLog, RefundIssuedLog, } from "../types/abi-interfaces/CrowdFundingAbi";


export async function handleCampaignCreated(log: CampaignCreatedLog): Promise<void> {
  // Place your code logic here
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
