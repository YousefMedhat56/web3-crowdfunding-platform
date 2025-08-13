// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";

contract Handler is Test {
    CrowdFunding public crowdFunding;

    string constant CAMPAIGN_NAME = "Test name";
    string constant CAMPAIGN_DESCRIPTION = "Test description";
    uint256 constant MIN_CAMPAIGN_GOAL = 1 ether;
    uint256 constant MAX_CAMPAIGN_GOAL = 100 ether;
    uint256 MIN_CAMPAIGN_DEADLINE;
    uint256 MAX_CAMPAIGN_DEADLINE;
    address[] campaignOwners;

    constructor(CrowdFunding _crowdFunding) {
        crowdFunding = _crowdFunding;
        MIN_CAMPAIGN_DEADLINE = block.timestamp + 1 days;
        MAX_CAMPAIGN_DEADLINE = block.timestamp + 100 days;
        campaignOwners = generateCampaignOwners();
    }

    function createCampaign(uint256 _campaignOwnerSeed, uint256 _goal, uint256 _deadline) public {
        address owner = getCamapaignOwnerFromSeed(_campaignOwnerSeed);

        _goal = bound(_goal, MIN_CAMPAIGN_GOAL, MAX_CAMPAIGN_GOAL);
        _deadline = bound(_deadline, MIN_CAMPAIGN_DEADLINE, MAX_CAMPAIGN_DEADLINE);

        vm.prank(owner);
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESCRIPTION, _goal, _deadline);
    }

    // HELPER FUNCTIONS
    function generateCampaignOwners() internal pure returns (address[] memory) {
        address[] memory _campaignOwners = new address[](10);

        for (uint160 i = 0; i < _campaignOwners.length; i++) {
            _campaignOwners[i] = address(i + 1);
        }

        return _campaignOwners;
    }

    function getCamapaignOwnerFromSeed(uint256 _seed) internal view returns (address) {
        return campaignOwners[_seed % campaignOwners.length];
    }
}
