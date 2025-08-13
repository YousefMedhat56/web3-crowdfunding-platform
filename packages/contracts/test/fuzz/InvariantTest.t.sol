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
}
