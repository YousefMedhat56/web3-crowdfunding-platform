// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";

contract DeployCrowdFunding is Script {
    function run() public returns (CrowdFunding) {
        vm.startBroadcast();
        CrowdFunding crowdFunding = new CrowdFunding();
        console.log("CrowdFunding deployed at: ", address(crowdFunding));
        vm.stopBroadcast();
        return crowdFunding;
    }
}
