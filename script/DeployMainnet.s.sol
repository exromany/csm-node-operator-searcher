// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {DeployBase} from "./DeployBase.s.sol";

contract DeployMainnet is DeployBase {
    constructor() DeployBase("mainnet", 1) {
        config.csModuleAddress = 0xdA7dE2ECdDfccC6c3AF10108Db212ACBBf9EA83F;
    }
}
