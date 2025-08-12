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

    function setUp() public {
        deployer = new DeployCrowdFunding();
        crowdFunding = deployer.run();
        CAMPAIGN_DEADLINE = block.timestamp + 1 days;
    }

    /*
    * TEST createCampaign
    */

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
}
