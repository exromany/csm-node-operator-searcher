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
            ICSModule.NodeOperator memory operator = csModule.getNodeOperator(
                i
            );

            bool matches = false;

            if (_searchMode == SearchMode.CURRENT_ADDRESSES) {
                matches = (operator.managerAddress == _addressToSearch ||
                    operator.rewardAddress == _addressToSearch);
            } else if (_searchMode == SearchMode.PROPOSED_ADDRESSES) {
                matches = (operator.proposedManagerAddress ==
                    _addressToSearch ||
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

        NodeOperatorShort[] memory tempResults = new NodeOperatorShort[](
            _limit
        );
        uint256 resultCount = 0;

        for (uint256 i = _offset; i < endIndex; i++) {
            ICSModule.NodeOperatorManagementProperties
                memory operator = csModule.getNodeOperatorManagementProperties(
                    i
                );

            bool matches = (operator.managerAddress == _addressToSearch ||
                operator.rewardAddress == _addressToSearch);

            if (matches) {
                tempResults[resultCount] = NodeOperatorShort({
                    id: i,
                    managerAddress: operator.managerAddress,
                    rewardAddress: operator.rewardAddress,
                    extendedManagerPermissions: operator
                        .extendedManagerPermissions
                });
                resultCount++;
            }
        }

        NodeOperatorShort[] memory results = new NodeOperatorShort[](
            resultCount
        );
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

        NodeOperatorProposed[] memory tempResults = new NodeOperatorProposed[](
            _limit
        );
        uint256 resultCount = 0;

        for (uint256 i = _offset; i < endIndex; i++) {
            ICSModule.NodeOperator memory operator = csModule.getNodeOperator(
                i
            );

            bool matches = (operator.proposedManagerAddress ==
                _addressToSearch ||
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

        NodeOperatorProposed[] memory results = new NodeOperatorProposed[](
            resultCount
        );
        for (uint256 i = 0; i < resultCount; i++) {
            results[i] = tempResults[i];
        }

        return results;
    }

    /**
     * @notice Retrieves the depositable validators count for a range of Node Operators.
     * @dev Returns an array where each element is the depositableValidatorsCount for the corresponding operator.
     *      The operator ID can be calculated as: operatorId = _offset + arrayIndex
     *
     *      Example usage:
     *      - Call with _offset=0, _limit=100 to get counts for operators 0-99
     *      - result[0] = depositableValidatorsCount for operator 0
     *      - result[50] = depositableValidatorsCount for operator 50
     *
     *      This is a lightweight, gas-efficient method to retrieve depositable validator counts
     *      for analytics and monitoring purposes.
     *
     * @param _offset The starting index (0-based) of Node Operators to query.
     * @param _limit The maximum number of operators to return counts for.
     * @return An array of uint32 values representing depositableValidatorsCount for each operator in the range.
     */
    function getNodeOperatorsDepositableValidatorsCount(
        uint256 _offset,
        uint256 _limit
    ) external view returns (uint32[] memory) {
        require(_limit > 0, "Limit must be greater than zero");

        uint256 totalOperators = csModule.getNodeOperatorsCount();

        if (_offset >= totalOperators) {
            return new uint32[](0);
        }

        uint256 endIndex = _offset + _limit;
        if (endIndex > totalOperators) {
            endIndex = totalOperators;
        }

        uint256 resultCount = endIndex - _offset;
        uint32[] memory results = new uint32[](resultCount);

        for (uint256 i = _offset; i < endIndex; i++) {
            ICSModule.NodeOperator memory operator = csModule.getNodeOperator(
                i
            );
            results[i - _offset] = operator.depositableValidatorsCount;
        }

        return results;
    }

    /**
     * @notice Retrieves deposit queue batches using linked-list traversal via batch.next() pointers.
     * @dev This function follows the queue's linked-list structure and respects the head pointer,
     *      ensuring only active batches in the queue are returned (between head and tail).
     *      It properly handles scenarios where batches have been skipped (head advanced past some indices).
     *
     *      Pagination approach:
     *      - Use cursorIndex=0 to start from the queue head
     *      - Extract next cursor from last batch: batches[batches.length - 1].next()
     *      - If returned array is empty, you've reached the end of the queue
     *      - If last batch's next() >= tail, you've reached the end
     *
     * @param _queuePriority The priority level of the queue to retrieve batches from.
     * @param _cursorIndex The batch index to start from (use 0 to start from head, or next() from previous page's last batch).
     * @param _limit The maximum number of batches to return.
     * @return batches An array of Batch structures traversed via next pointers. Extract next cursor via batches[length-1].next().
     */
    function getDepositQueueBatches(
        uint256 _queuePriority,
        uint128 _cursorIndex,
        uint256 _limit
    ) external view returns (Batch[] memory batches) {
        require(_limit > 0, "Limit must be greater than zero");
        require(
            _queuePriority <= csModule.QUEUE_LOWEST_PRIORITY(),
            "Invalid queue priority"
        );

        (uint128 head, uint128 tail) = csModule.depositQueuePointers(
            _queuePriority
        );

        // If queue is empty, return empty array
        if (head == tail) {
            return new Batch[](0);
        }

        // Validate cursor is within active queue range
        if (_cursorIndex != 0 && _cursorIndex < head) {
            revert("Cursor is behind queue head");
        }

        // Start from head if cursor is 0, otherwise use the provided cursor
        uint128 currentIndex = _cursorIndex == 0 ? head : _cursorIndex;

        // If current index is at or beyond tail, we're done
        if (currentIndex >= tail) {
            return new Batch[](0);
        }

        // Allocate temporary array with max possible size
        Batch[] memory tempBatches = new Batch[](_limit);
        uint256 count = 0;

        // Traverse the linked list using next() pointers
        while (count < _limit && currentIndex < tail) {
            Batch batch = csModule.depositQueueItem(
                _queuePriority,
                currentIndex
            );
            tempBatches[count] = batch;
            count++;

            // Get next index from batch
            uint128 nextIndex = batch.next();

            // If next points to tail or beyond, we've reached the end
            if (nextIndex >= tail) {
                break;
            }

            currentIndex = nextIndex;
        }

        // Create result array with actual size
        batches = new Batch[](count);
        for (uint256 i = 0; i < count; i++) {
            batches[i] = tempBatches[i];
        }

        return batches;
    }
}
