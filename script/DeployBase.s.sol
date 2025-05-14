// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import "../src/NodeOperatorSearcher.sol";
import "../src/interfaces/ICSModule.sol";

struct DeployParams {
    address csModuleAddress;
}

contract DeployBase is Script {
    DeployParams internal config;
    string internal chainName;
    uint256 internal chainId;

    error ChainIdMismatch(uint256 actual, uint256 expected);

    constructor(string memory _chainName, uint256 _chainId) {
        chainName = _chainName;
        chainId = _chainId;
    }

    function run() external virtual {
        if (chainId != block.chainid) {
            revert ChainIdMismatch({actual: block.chainid, expected: chainId});
        }

        vm.startBroadcast();

        // Deploy NodeOperatorSearcher, passing the CSModule address
        new NodeOperatorSearcher(address(config.csModuleAddress));

        vm.stopBroadcast();
    }
}
