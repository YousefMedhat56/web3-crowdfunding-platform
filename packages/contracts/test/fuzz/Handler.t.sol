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
        contributors = generateContributors();
    }

    function createCampaign(uint256 _campaignOwnerSeed, uint256 _goal, uint256 _deadline) public {
        address owner = getCampaignOwnerFromSeed(_campaignOwnerSeed);

        _goal = bound(_goal, MIN_CAMPAIGN_GOAL, MAX_CAMPAIGN_GOAL);
        _deadline = bound(_deadline, MIN_CAMPAIGN_DEADLINE, MAX_CAMPAIGN_DEADLINE);

        vm.warp(MIN_CAMPAIGN_DEADLINE - 1);
        vm.prank(owner);
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESCRIPTION, _goal, _deadline);
    }

    modifier checkCampaignsCount() {
        if (crowdFunding.campaignCount() == 0) {
            return;
        }
        _;
    }

    function contribute(uint256 _contributorSeed, uint256 _campaignIdSeed, uint256 _amount)
        public
        payable
        checkCampaignsCount
    {
        address contributor = getContributorFromSeed(_contributorSeed);
        uint256 campaignId = getCampaignIdFromSeed(_campaignIdSeed);
        bool isWithdrawn = crowdFunding.getCampaignWithdrawnStatus(campaignId);

        _amount = bound(_amount, MIN_CONTRIBUTION_AMOUNT, MAX_CONTRIBUTION_AMOUNT);

        if (isWithdrawn) {
            return;
        }

        if (contributor.balance < _amount) {
            return;
        }
        vm.warp(MIN_CAMPAIGN_DEADLINE - 1);
        vm.prank(contributor);
        crowdFunding.contribute{value: _amount}(campaignId);
    }

    function withdrawFunds(uint256 _campaignIdSeed) public checkCampaignsCount {
        uint256 campaignId = getCampaignIdFromSeed(_campaignIdSeed);
        address owner = crowdFunding.getCampaignOwner(campaignId);
        uint256 raised = crowdFunding.getCampaignRaised(campaignId);
        uint256 goal = crowdFunding.getCampaignGoal(campaignId);
        bool isWithdrawn = crowdFunding.getCampaignWithdrawnStatus(campaignId);

        if (isWithdrawn) {
            return;
        }
        if (raised < goal) {
            return;
        }

        vm.warp(MAX_CAMPAIGN_DEADLINE + 1);
        vm.prank(owner);
        crowdFunding.withdrawFunds(campaignId);
    }

    // HELPER FUNCTIONS

    function generateCampaignOwners() internal pure returns (address[] memory) {
        address[] memory _campaignOwners = new address[](10);
        uint160 start = 100; // Start from 0x100 to avoid precompiles
        uint160 end = 110;
        for (uint160 i = start; i < end; i++) {
            uint160 index = i - start;
            _campaignOwners[index] = address(uint160(start + index));
        }
        return _campaignOwners;
    }

    function getCampaignOwnerFromSeed(uint256 _seed) internal view returns (address) {
        return campaignOwners[_seed % campaignOwners.length];
    }

    function generateContributors() internal returns (address[] memory) {
        address[] memory _contributors = new address[](100);
        uint160 start = 200;
        uint160 end = 300;
        for (uint160 i = start; i < end; i++) {
            uint160 index = i - start;
            _contributors[index] = address(uint160(start + index));
            vm.deal(_contributors[index], DEFAULT_CONTRIBUTOR_BALANCE);
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
