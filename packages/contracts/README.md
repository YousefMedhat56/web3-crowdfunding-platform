
# CrowdFunding Smart Contract

## Overview
The CrowdFunding smart contract enables users to create, fund, and manage crowdfunding campaigns. <br>Each campaign has a goal, deadline, and owner, allowing contributors to send funds and owners to withdraw funds if the goal is met, or contributors to claim refunds if the campaign fails. The contract is written in Solidity and developed using the Foundry framework.

## Requirements
Ensure you have the following tools installed:
1. Solidity
2. Foundry
3. Forge

**Dependencies**: Install forge-std
  ```
  forge install foundry-rs/forge-std
  ```

## Testing

### Unit Testing
Verify the functionality of individual contract methods, ensuring correct behavior for campaign creation, contributions, withdrawals, and refunds.

- **Location**: [test/unit/CrowdFundingTest.t.sol](./test/unit/CrowdFundingTest.t.sol)
- **Run Tests**:
  ```
  forge test --match-path test/unit/CrowdFundingTest.t.sol
  ```

### Invariant Testing
Invariant tests ensure system-wide properties hold under various conditions and edge cases.

- **Location**: [test/fuzz/InvariantTest.t.sol](./test/fuzz/InvariantTest.t.sol)
- **Run Tests**:
  ```
  forge test --match-path test/fuzz/InvariantTest.t.sol
  ```

## Deployment

- **Deployment Script**:
  - Located in [script/DeployCrowdFunding.s.sol](./script/DeployCrowdFunding.s.sol).
- **Deploy locally to Anvil**:
  1. Start Anvil:
     ```
     anvil --host 0.0.0.0 --port 8545
     ```
  2. Deploy:
     ```
     forge script script/DeployCrowdFunding.s.sol --rpc-url http://localhost:8545 --private-key <ANVIL_PRIVATE_KEY> --broadcast
     ```
  3. Note the contract address in the output.

## Contract Details
The `CrowdFunding` contract supports the following functionality:
- **Campaign Creation**: Users create campaigns with a unique ID, name, description, funding goal, and deadline. Emits `CampaignCreated`.
- **Contributions**: Users contribute ETH to a campaign. Emits `ContributionReceived`.
- **Withdrawals**: Campaign owners can withdraw funds if the goal is met and the deadline has passed. Emits `FundsWithdrawn`.
- **Refunds**: Contributors can claim refunds if the goal is not met after the deadline. Emits `RefundIssued`.
- **Events**:
  - `CampaignCreated(uint256 indexed campaign_id, address indexed owner, string name, string description, uint256 goal, uint256 deadline)`
  - `ContributionReceived(uint256 indexed campaign_id, address indexed contributor, uint256 amount)`
  - `FundsWithdrawn(uint256 indexed campaign_id, uint256 amount)`
  - `RefundIssued(uint256 indexed campaign_id, address indexed contributor, uint256 amount)`

## Usage
Interact with the deployed contract using `cast` or the frontend app.

- **Create a Campaign**:
  ```
  cast send <CONTRACT_ADDRESS> "createCampaign(string,string,uint256,uint256)" "My Campaign" "Description" 1000000000000000000 1697059200 --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY> --value 0
  ```
- **Contribute**:
  ```
  cast send <CONTRACT_ADDRESS> "contribute(uint256)" 1 --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY> --value 0.1ether
  ```
- **Withdraw Funds**:
  ```
  cast send <CONTRACT_ADDRESS> "withdrawFunds(uint256)" 1 --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY>
  ```
- **Claim Refund**:
  ```
  cast send <CONTRACT_ADDRESS> "refund(uint256)" 1 --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY>
  ```
- **Check Campaign Details**:
  ```
  cast call <CONTRACT_ADDRESS> "campaigns(uint256)(address,string,string,uint256,uint256,uint256,bool)" 1 --rpc-url http://localhost:8545
  ```

