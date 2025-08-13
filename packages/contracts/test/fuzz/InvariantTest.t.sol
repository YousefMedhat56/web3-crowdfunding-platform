// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {StdInvariant} from "forge-std/StdInvariant.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployCrowdFunding} from "../../script/DeployCrowdFunding.s.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantTest is StdInvariant, Test {
    DeployCrowdFunding public deployer;
    CrowdFunding public crowdFunding;
    Handler handler;

    function setUp() public {
        deployer = new DeployCrowdFunding();
        crowdFunding = deployer.run();
        handler = new Handler(crowdFunding);
        targetContract(address(handler));
    }

    /**
     * @notice Checks that the contract balance is equal to the sum of all raised funds of non withdrawn campaigns
     */
    function invariant_ContractBalanceShouldEqualAllNonWithdrawnCampaignsRaised() public view {
        uint256 totalRaised = 0;
        for (uint256 i = 0; i < crowdFunding.campaignCount(); i++) {
            // check if the campaign is not withdrawn
            if (crowdFunding.getCampaignWithdrawnStatus(i) == false) {
                totalRaised += crowdFunding.getCampaignRaised(i);
            }
        }
        console.log("Contract Balance", address(crowdFunding).balance);
        console.log("Total Raised", totalRaised);
        assertEq(address(crowdFunding).balance, totalRaised);
    }

    /**
     * @notice Checks that the raised funds of a campaign should equal the total of all contributions of the campaign
     */
    function invariant_CampaignRaisedShouldEqualTotalCampaignContributions() public view {
        for (uint256 i = 0; i < crowdFunding.campaignCount(); i++) {
            uint256 totalContributions = 0;
            uint256 campaignRaised = crowdFunding.getCampaignRaised(i);
            address[] memory contributors = crowdFunding.getCampaignContributors(i);
            for (uint256 j = 0; j < contributors.length; j++) {
                totalContributions += crowdFunding.getContribution(i, contributors[j]);
            }
            console.log("Campaign Raised", campaignRaised);
            console.log("Total Contributions", totalContributions);
            assertEq(campaignRaised, totalContributions);
        }
    }
}
