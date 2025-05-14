// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DeployBase} from "./DeployBase.s.sol";

contract DeployHoodi is DeployBase {
    constructor() DeployBase("hoodi", 560048) {
        config.csModuleAddress = 0x79CEf36D84743222f37765204Bec41E92a93E59d;
    }
}
