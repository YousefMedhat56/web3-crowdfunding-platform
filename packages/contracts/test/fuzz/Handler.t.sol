// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";

contract Handler is Test {
    CrowdFunding public crowdFunding;

    string constant CAMPAIGN_NAME = "Test name";
    string constant CAMPAIGN_DESCRIPTION = "Test description";
    uint256 constant MIN_CAMPAIGN_GOAL = 1 ether;
    uint256 constant MAX_CAMPAIGN_GOAL = 100 ether;
    uint256 constant MIN_CONTRIBUTION_AMOUNT = 0.1 ether;
    uint256 constant MAX_CONTRIBUTION_AMOUNT = 10 ether;
    uint256 constant DEFAULT_CONTRIBUTOR_BALANCE = 10 ether;
    uint256 MIN_CAMPAIGN_DEADLINE;
    uint256 MAX_CAMPAIGN_DEADLINE;
    address[] campaignOwners;
    address[] contributors;

    constructor(CrowdFunding _crowdFunding) {
        crowdFunding = _crowdFunding;
        MIN_CAMPAIGN_DEADLINE = block.timestamp + 1 days;
        MAX_CAMPAIGN_DEADLINE = block.timestamp + 100 days;
        campaignOwners = generateCampaignOwners();
        contributors = generateContibutors();
    }

    function createCampaign(uint256 _campaignOwnerSeed, uint256 _goal, uint256 _deadline) public {
        address owner = getCamapaignOwnerFromSeed(_campaignOwnerSeed);

        _goal = bound(_goal, MIN_CAMPAIGN_GOAL, MAX_CAMPAIGN_GOAL);
        _deadline = bound(_deadline, MIN_CAMPAIGN_DEADLINE, MAX_CAMPAIGN_DEADLINE);

        vm.prank(owner);
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESCRIPTION, _goal, _deadline);
    }

    function contribute(uint256 _contributorSeed, uint256 _campaignIdSeed, uint256 _amount) public payable {
        if (crowdFunding.campaignCount() == 0) {
            return;
        }
        address contributor = getContributorFromSeed(_contributorSeed);
        uint256 campaignId = getCampaignIdFromSeed(_campaignIdSeed);
        _amount = bound(_amount, MIN_CONTRIBUTION_AMOUNT, MAX_CONTRIBUTION_AMOUNT);

        if (contributor.balance < _amount) {
            return;
        }
        vm.prank(contributor);
        crowdFunding.contribute{value: _amount}(campaignId);
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

    function generateContibutors() internal returns (address[] memory) {
        address[] memory _contributors = new address[](100);

        for (uint160 i = 0; i < _contributors.length; i++) {
            _contributors[i] = address(i + 1);
            vm.deal(_contributors[i], DEFAULT_CONTRIBUTOR_BALANCE);
        }

        return _contributors;
    }

    function getContributorFromSeed(uint256 _seed) internal view returns (address) {
        return contributors[_seed % contributors.length];
    }

    function getCampaignIdFromSeed(uint256 _seed) internal view returns (uint256) {
        return (_seed % crowdFunding.campaignCount());
    }
}
