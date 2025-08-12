// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";
import {DeployCrowdFunding} from "../../script/DeployCrowdFunding.s.sol";

contract CrowdFundingTest is Test {
    DeployCrowdFunding public deployer;
    CrowdFunding public crowdFunding;

    address constant CAMPAIGN_OWNER = address(0x1);
    string constant CAMPAIGN_NAME = "Test";
    string constant CAMPAIGN_DESC = "Test Description";
    uint256 constant CAMPAIGN_GOAL = 10 ether;
    uint256 CAMPAIGN_DEADLINE;

    address constant CONTRIBUTOR_1 = address(0x2);
    address constant CONTRIBUTOR_2 = address(0x3);
    uint256 constant CONTRIBUTOR_BALANCE = 2 ether;

    function setUp() public {
        deployer = new DeployCrowdFunding();
        crowdFunding = deployer.run();
        CAMPAIGN_DEADLINE = block.timestamp + 1 days;
    }

    // ##########################
    // TEST createCampaign
    // ##########################

    function testRevertIfZeroGoal() public {
        vm.prank(CAMPAIGN_OWNER);
        vm.expectRevert(CrowdFunding.CrowdFunding__CannotBeZero.selector);
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESC, 0, CAMPAIGN_DEADLINE);
    }

    function testRevertIfNameIsEmpty() public {
        vm.prank(CAMPAIGN_OWNER);
        vm.expectRevert(CrowdFunding.CrowdFunding__EmptyString.selector);
        crowdFunding.createCampaign("", CAMPAIGN_DESC, CAMPAIGN_GOAL, CAMPAIGN_DEADLINE);
    }

    function testRevertIfInvalidDeadline() public {
        uint256 invalidDeadline = block.timestamp - 1;
        vm.prank(CAMPAIGN_OWNER);
        vm.expectRevert(CrowdFunding.CrowdFunding__InvalidDeadlineDate.selector);
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESC, CAMPAIGN_GOAL, invalidDeadline);
    }

    function testCreateCampaignSuccess() public {
        vm.prank(CAMPAIGN_OWNER);
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESC, CAMPAIGN_GOAL, CAMPAIGN_DEADLINE);
        (address owner, string memory name, string memory desc, uint256 goal,, uint256 deadline, bool isWithdrawn) =
            crowdFunding.s_campaigns(0);

        assertEq(owner, CAMPAIGN_OWNER);
        assertEq(name, CAMPAIGN_NAME);
        assertEq(desc, CAMPAIGN_DESC);
        assertEq(goal, CAMPAIGN_GOAL);
        assertEq(deadline, CAMPAIGN_DEADLINE);
        assertEq(isWithdrawn, false);
        assertEq(crowdFunding.campaignCount(), 1);
    }

    // ##########################
    // TEST contribute
    // ##########################
    modifier createCampaign() {
        crowdFunding.createCampaign(CAMPAIGN_NAME, CAMPAIGN_DESC, CAMPAIGN_GOAL, CAMPAIGN_DEADLINE);
        vm.deal(CONTRIBUTOR_1, CONTRIBUTOR_BALANCE);
        vm.deal(CONTRIBUTOR_2, CONTRIBUTOR_BALANCE);
        _;
    }

    function testRevertIfCampaignDoesNotExist() public {
        vm.deal(CONTRIBUTOR_1, CONTRIBUTOR_BALANCE);
        vm.prank(CONTRIBUTOR_1);
        vm.expectRevert(CrowdFunding.CrowdFunding__CampaignDoesNotExist.selector);
        crowdFunding.contribute{value: 1 ether}(0);
    }

    function testRevertIfContributionAfterDeadline() public createCampaign {
        vm.prank(CONTRIBUTOR_1);
        vm.warp(block.timestamp + 2 days);
        vm.expectRevert(CrowdFunding.CrowdFunding__CampaignFinished.selector);
        crowdFunding.contribute{value: 1 ether}(0);
    }

    function testRevertIfContributionValueIsZero() public createCampaign {
        vm.prank(CONTRIBUTOR_1);
        vm.expectRevert(CrowdFunding.CrowdFunding__CannotBeZero.selector);
        crowdFunding.contribute(0);
    }

    function testContributeSuccess() public createCampaign {
        vm.prank(CONTRIBUTOR_1);
        crowdFunding.contribute{value: 1 ether}(0);
        vm.prank(CONTRIBUTOR_2);
        crowdFunding.contribute{value: 2 ether}(0);

        assertEq(crowdFunding.getContribution(0, CONTRIBUTOR_1), 1 ether);
        assertEq(crowdFunding.getContribution(0, CONTRIBUTOR_2), 2 ether);
        assertEq(crowdFunding.getCampaignRaised(0), 3 ether);
    }
}
