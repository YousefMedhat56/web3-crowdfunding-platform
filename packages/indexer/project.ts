import {
  EthereumProject,
  EthereumDatasourceKind,
  EthereumHandlerKind,
} from "@subql/types-ethereum";

import * as dotenv from 'dotenv';
import path from 'path';

const mode = process.env.NODE_ENV || 'production';

// Load the appropriate .env file
const dotenvPath = path.resolve(__dirname, `.env${mode === 'production' ? ".production" : ".develop"}`);
dotenv.config({ path: dotenvPath, quiet: true });

// Can expand the Datasource processor types via the generic param
const project: EthereumProject = {
  specVersion: "1.0.0",
  version: "0.0.1",
  name: "crowdfunding-indexer",
  description:
    "An indexer for the Crowdfunding contract",
  runner: {
    node: {
      name: "@subql/node-ethereum",
      version: ">=3.0.0",
    },
    query: {
      name: "@subql/query",
      version: "*",
    },
  },
  schema: {
    file: "./schema.graphql",
  },
  network: {
    chainId: process.env.CHAIN_ID!,
    endpoint: process.env.ENDPOINT!
  },
  dataSources: [{
    kind: EthereumDatasourceKind.Runtime,
    startBlock: 1,
    options: {
      abi: 'CrowdFundingAbi',
      address: process.env.CONTRACT_ADDRESS!,
    },
    assets: new Map([['CrowdFundingAbi', { file: './abis/CrowdFunding.abi.json' }]]),
    mapping: {
      file: './dist/index.js',
      handlers: [
        {
          handler: "handleCampaignCreated",
          kind: EthereumHandlerKind.Event,
          filter: {
            topics: [
              "CampaignCreated(uint256,address,string,string,uint256,uint256)"
            ]
          }
        },
        {
          handler: "handleContributionReceived",
          kind: EthereumHandlerKind.Event,
          filter: {
            topics: [
              "ContributionReceived(uint256,address,uint256)"
            ]
          }
        },
        {
          handler: "handleFundsWithdrawn",
          kind: EthereumHandlerKind.Event,
          filter: {
            topics: [
              "FundsWithdrawn(uint256,address,uint256)"
            ]
          }
        },
        {
          handler: "handleRefundIssued",
          kind: EthereumHandlerKind.Event,
          filter: {
            topics: [
              "RefundIssued(uint256,address,uint256)"
            ]
          }
        }
      ]
    }
  },

  ],
  repository: "https://github.com/subquery/ethereum-subql-starter",
};

// Must set default to the project instance
export default project;
