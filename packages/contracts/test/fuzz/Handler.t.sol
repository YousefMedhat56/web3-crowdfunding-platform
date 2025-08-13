// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";

contract Handler is Test {
    CrowdFunding public crowdFunding;

    constructor(CrowdFunding _crowdFunding) {
        crowdFunding = _crowdFunding;
    }
}
