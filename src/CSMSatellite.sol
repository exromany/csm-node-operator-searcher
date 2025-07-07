// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./interfaces/ICSModule.sol";
import {Batch} from "./interfaces/ICSModule.sol";

struct NodeOperatorShort {
    uint256 id;
    address managerAddress;
    address rewardAddress;
    bool extendedManagerPermissions;
}

struct NodeOperatorProposed {
    uint256 id;
    address proposedManagerAddress;
    address proposedRewardAddress;
}

enum SearchMode {
    CURRENT_ADDRESSES,
    PROPOSED_ADDRESSES,
    ALL_ADDRESSES
}

contract CSMSatellite {
    ICSModule public immutable csModule;

    constructor(address _csModuleAddress) {
        require(
            _csModuleAddress != address(0),
            "CSModule address cannot be zero"
        );
        csModule = ICSModule(_csModuleAddress);
    }

    /**
     * @notice Finds Node Operator IDs by a given address, searching within a specified range.
     * @param _addressToSearch The address to match against Node Operator addresses.
     * @param _offset The starting index (0-based) of Node Operators to check.
     * @param _limit The maximum number of Node Operator IDs to return in this call.
     * @param _searchMode The search mode determining which addresses to check (current, proposed, or all).
     * @return matchingOperatorIds An array containing the IDs of matching Node Operators found within the page.
     */
    function findNodeOperatorsByAddress(
        address _addressToSearch,
        uint256 _offset,
        uint256 _limit,
        SearchMode _searchMode
    ) external view returns (uint256[] memory) {
        require(_addressToSearch != address(0), "Address cannot be zero");
        require(_limit > 0, "Limit must be greater than zero");

        uint256 totalOperators = csModule.getNodeOperatorsCount();

        if (_offset >= totalOperators) {
            return new uint256[](0);
        }

        uint256 endIndex = _offset + _limit;
        if (endIndex > totalOperators) {
            endIndex = totalOperators;
        }

        uint256[] memory tempResults = new uint256[](_limit);
        uint256 resultCount = 0;

        for (uint256 i = _offset; i < endIndex; i++) {
            ICSModule.NodeOperator memory operator = csModule.getNodeOperator(i);

            bool matches = false;

            if (_searchMode == SearchMode.CURRENT_ADDRESSES) {
                matches = (operator.managerAddress == _addressToSearch ||
                          operator.rewardAddress == _addressToSearch);
            } else if (_searchMode == SearchMode.PROPOSED_ADDRESSES) {
                matches = (operator.proposedManagerAddress == _addressToSearch ||
                          operator.proposedRewardAddress == _addressToSearch);
            } else if (_searchMode == SearchMode.ALL_ADDRESSES) {
                matches = (operator.managerAddress == _addressToSearch ||
                          operator.rewardAddress == _addressToSearch ||
                          operator.proposedManagerAddress == _addressToSearch ||
                          operator.proposedRewardAddress == _addressToSearch);
            }

            if (matches) {
                tempResults[resultCount] = i;
                resultCount++;
            }
        }

        uint256[] memory results = new uint256[](resultCount);
        for (uint256 i = 0; i < resultCount; i++) {
            results[i] = tempResults[i];
        }

        return results;
    }

    /**
     * @notice Finds Node Operators by a given address and returns their details, searching within a specified range.
     * @dev Only searches current addresses (managerAddress and rewardAddress), not proposed addresses.
     * @param _addressToSearch The address to match against Node Operator current addresses.
     * @param _offset The starting index (0-based) of Node Operators to check.
     * @param _limit The maximum number of Node Operators to return in this call.
     * @return operators An array containing the details of matching Node Operators found within the page.
     */
    function getNodeOperatorsByAddress(
        address _addressToSearch,
        uint256 _offset,
        uint256 _limit
    ) external view returns (NodeOperatorShort[] memory) {
        require(_addressToSearch != address(0), "Address cannot be zero");
        require(_limit > 0, "Limit must be greater than zero");

        uint256 totalOperators = csModule.getNodeOperatorsCount();

        if (_offset >= totalOperators) {
            return new NodeOperatorShort[](0);
        }

        uint256 endIndex = _offset + _limit;
        if (endIndex > totalOperators) {
            endIndex = totalOperators;
        }

        NodeOperatorShort[] memory tempResults = new NodeOperatorShort[](_limit);
        uint256 resultCount = 0;

        for (uint256 i = _offset; i < endIndex; i++) {
            ICSModule.NodeOperatorManagementProperties memory operator = csModule.getNodeOperatorManagementProperties(i);

            bool matches = (operator.managerAddress == _addressToSearch ||
                          operator.rewardAddress == _addressToSearch);

            if (matches) {
                tempResults[resultCount] = NodeOperatorShort({
                    id: i,
                    managerAddress: operator.managerAddress,
                    rewardAddress: operator.rewardAddress,
                    extendedManagerPermissions: operator.extendedManagerPermissions
                });
                resultCount++;
            }
        }

        NodeOperatorShort[] memory results = new NodeOperatorShort[](resultCount);
        for (uint256 i = 0; i < resultCount; i++) {
            results[i] = tempResults[i];
        }

        return results;
    }

    /**
     * @notice Finds Node Operators by a given address matching proposed addresses, searching within a specified range.
     * @dev Only searches proposed addresses (proposedManagerAddress and proposedRewardAddress).
     * @param _addressToSearch The address to match against Node Operator proposed addresses.
     * @param _offset The starting index (0-based) of Node Operators to check.
     * @param _limit The maximum number of Node Operators to return in this call.
     * @return operators An array containing the IDs and proposed addresses of matching Node Operators found within the page.
     */
    function getNodeOperatorsByProposedAddress(
        address _addressToSearch,
        uint256 _offset,
        uint256 _limit
    ) external view returns (NodeOperatorProposed[] memory) {
        require(_addressToSearch != address(0), "Address cannot be zero");
        require(_limit > 0, "Limit must be greater than zero");

        uint256 totalOperators = csModule.getNodeOperatorsCount();

        if (_offset >= totalOperators) {
            return new NodeOperatorProposed[](0);
        }

        uint256 endIndex = _offset + _limit;
        if (endIndex > totalOperators) {
            endIndex = totalOperators;
        }

        NodeOperatorProposed[] memory tempResults = new NodeOperatorProposed[](_limit);
        uint256 resultCount = 0;

        for (uint256 i = _offset; i < endIndex; i++) {
            ICSModule.NodeOperator memory operator = csModule.getNodeOperator(i);

            bool matches = (operator.proposedManagerAddress == _addressToSearch ||
                          operator.proposedRewardAddress == _addressToSearch);

            if (matches) {
                tempResults[resultCount] = NodeOperatorProposed({
                    id: i,
                    proposedManagerAddress: operator.proposedManagerAddress,
                    proposedRewardAddress: operator.proposedRewardAddress
                });
                resultCount++;
            }
        }

        NodeOperatorProposed[] memory results = new NodeOperatorProposed[](resultCount);
        for (uint256 i = 0; i < resultCount; i++) {
            results[i] = tempResults[i];
        }

        return results;
    }

    /**
     * @notice Retrieves deposit queue batches with pagination using direct access to batch indices.
     * @param _queuePriority The priority level of the queue to retrieve batches from.
     * @param _startIndex The starting index in the queue to begin retrieval.
     * @param _limit The maximum number of batches to return.
     * @return batches An array of Batch structures within the specified range.
     */
    function getDepositQueueBatches(
        uint256 _queuePriority,
        uint128 _startIndex,
        uint256 _limit
    ) external view returns (Batch[] memory) {
        require(_limit > 0, "Limit must be greater than zero");
        require(_queuePriority <= csModule.QUEUE_LOWEST_PRIORITY(), "Invalid queue priority");

        (, uint128 tail) = csModule.depositQueuePointers(_queuePriority);

        // If queue is empty or start index is beyond tail
        if (_startIndex >= tail) {
            return new Batch[](0);
        }

        uint128 endIndex = _startIndex + uint128(_limit);
        if (endIndex > tail) {
            endIndex = tail;
        }

        uint256 batchCount = endIndex - _startIndex;
        Batch[] memory batches = new Batch[](batchCount);

        for (uint128 i = _startIndex; i < endIndex; i++) {
            batches[i - _startIndex] = csModule.depositQueueItem(_queuePriority, i);
        }

        return batches;
    }

}
