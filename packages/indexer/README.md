# CrowdFunding SubQuery Indexer

## Overview
A data indexing solution for the `CrowdFunding` contract. Built using the SubQuery framework, it indexes blockchain events to provide a GraphQL API for querying campaign, contribution, withdrawal, and refund data. The indexer processes events emitted by the smart contract and stores them in a Postgres database, enabling efficient data retrieval for dApps.

## Setup
To set up and run the indexer, ensure the following prerequisites and steps are completed.

### Prerequisites

- **Docker**: Required for running Postgres and SubQuery services.

- **SubQuery CLI**
  ```
  npm install -g @subql/cli
  ```

### Installation
1. **Clone the Repository**:
   ```
   git clone https://github.com/YousefMedhat56/web3-crowdfunding-platform.git
   cd packages/indexer
   ```
2. **Install Dependencies**:
   ```
   npm install
   ```
3. **Set the environment variables**:
Create `.env.develop` file, then add:
   ```
   ENDPOINT = <ethereum-node-url> # for example: http://127.0.0.1:8545 (if using anvil)
   CHAIN_ID = <network-chain-id> # for example: 31337
   CONTRACT_ADDRESS = <crowdfunding-contract-address>
   ```
4. **Start the server**:
   ```
   npm run dev
   ```
The indexer should be running on `localhost:3000`

## Project Structure
- `schema.graphql`: Defines GraphQL entities (`Campaign`, `Contribution`, `Withdrawal`, `Refund`).
- `project.ts`: Configures the SubQuery project (network, data sources, handlers).
- `src/mappings/mappingHandlers.ts`: Handles blockchain events:
  - `handleCampaignCreated`: Processes `CampaignCreated` events.
  - `handleContributionReceived`: Updates contributions and campaign data.
  - `handleFundsWithdrawn`: Records withdrawals and updates campaign status.
  - `handleRefundIssued`: Manages refunds and updates contribution status.
- `abis/CrowdFunding.abi.json`: Contract ABI.
- `docker-compose.yml`: Defines Docker services (Postgres, `subql-node`, `subql-query`).

## Troubleshooting
- **Health Check Failures**:
  - Check `subql-query` health:
    ```
    curl http://localhost:3000/health
    ```
  - Verify `subquery-node` health:
    ```
    curl http://localhost:8090/health
    ```

