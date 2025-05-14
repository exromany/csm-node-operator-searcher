// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DeployBase} from "./DeployBase.s.sol";

contract DeployHolesky is DeployBase {
    constructor() DeployBase("holesky", 17000) {
        config.csModuleAddress = 0x4562c3e63c2e586cD1651B958C22F88135aCAd4f;
    }
}
