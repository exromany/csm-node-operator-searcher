// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./interfaces/ICSModule.sol";

contract CSMSatellite {
    enum SearchMode {
        CURRENT_ADDRESSES,
        PROPOSED_ADDRESSES,
        ALL_ADDRESSES
    }

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
     * @param _addressToSearch The address to match against Node Operator managerAddress or rewardAddress.
     * @param _offset The starting index (0-based) of Node Operators to check.
     * @param _limit The maximum number of Node Operator IDs to return in this call.
     * @return matchingOperatorIds An array containing the IDs of matching Node Operators found within the page.
     */
    function findNodeOperatorsByAddress(
        address _addressToSearch,
        uint256 _offset,
        uint256 _limit,
        SearchMode _searchMode
    ) external view returns (uint256[] memory) {
        uint256 totalOperators = csModule.getNodeOperatorsCount();

        if (_limit == 0 || _offset >= totalOperators) {
            return new uint256[](0);
        }

        uint256 iterationUpperBound = _offset + _limit;
        if (iterationUpperBound > totalOperators) {
            iterationUpperBound = totalOperators;
        }

        uint256 matchesCount = 0;
        uint256[] memory matchingOperatorIds = new uint256[](_limit);

        for (
            uint256 currentOperatorId = _offset;
            currentOperatorId < iterationUpperBound;
            ++currentOperatorId
        ) {
            ICSModule.NodeOperator memory operator = csModule.getNodeOperator(
                currentOperatorId
            );

            bool matched = false;

            if (
                _searchMode == SearchMode.CURRENT_ADDRESSES ||
                _searchMode == SearchMode.ALL_ADDRESSES
            ) {
                matched = (operator.managerAddress == _addressToSearch ||
                    operator.rewardAddress == _addressToSearch);
            }

            if (
                !matched &&
                (_searchMode == SearchMode.PROPOSED_ADDRESSES ||
                    _searchMode == SearchMode.ALL_ADDRESSES)
            ) {
                matched = (operator.proposedManagerAddress ==
                    _addressToSearch ||
                    operator.proposedRewardAddress == _addressToSearch);
            }

            if (matched) {
                matchingOperatorIds[matchesCount++] = currentOperatorId;
            }
        }

        // Trim the array to the actual number of matches
        assembly {
            mstore(matchingOperatorIds, matchesCount)
        }

        return matchingOperatorIds;
    }

    struct DepositQueueSlot {
        uint64 keysCount;
        uint256 keysOffset;
    }

    struct DepositQueueInfo {
        uint256 totalQueueKeys;
        DepositQueueSlot[] slots;
    }

    function getDepositQueueSlots(
        uint256 _nodeOperatorId,
        uint256 queuePriority
    ) external view returns (DepositQueueInfo memory) {
        (uint128 head, uint128 tail) = csModule.depositQueuePointers(
            queuePriority
        );
        uint256 totalQueueKeys = 0;

        uint256 totalQueueItems = tail - head;

        DepositQueueSlot[] memory matchingSlots = new DepositQueueSlot[](
            totalQueueItems
        );

        uint128 currentIndex = head;
        uint128 currentMatchingSlotIndex = 0;

        // Second pass to populate the matchingSlots array
        while (currentIndex != tail) {
            Batch batch = csModule.depositQueueItem(
                queuePriority,
                currentIndex
            );

            if (batch.noId() == _nodeOperatorId) {
                matchingSlots[currentMatchingSlotIndex] = DepositQueueSlot({
                    keysCount: batch.keys(),
                    keysOffset: totalQueueKeys
                });
                currentMatchingSlotIndex++;
            }

            totalQueueKeys += batch.keys();

            currentIndex = batch.next();
        }

        // Trim the array to the actual number of matches
        assembly {
            mstore(matchingSlots, currentMatchingSlotIndex)
        }

        return DepositQueueInfo(totalQueueKeys, matchingSlots);
    }

    /**
     * @notice Returns a limited range of batches from a specified deposit queue.
     * @param queuePriority The priority of the deposit queue (0 for high, 1 for low).
     * @param _offset The starting index (0-based) of batches to return.
     * @param _limit The maximum number of batches to return in this call.
     * @return batches An array containing the batches found within the specified range.
     */
    function getDepositQueueBatches(
        uint256 queuePriority,
        uint256 _offset,
        uint256 _limit
    ) external view returns (Batch[] memory) {
        (uint128 head, uint128 tail) = csModule.depositQueuePointers(
            queuePriority
        );
        uint256 totalQueueItems = tail - head;

        if (_limit == 0 || _offset >= totalQueueItems) {
            return new Batch[](0);
        }

        uint256 iterationUpperBound = _offset + _limit;
        if (iterationUpperBound > totalQueueItems) {
            iterationUpperBound = totalQueueItems;
        }

        Batch[] memory batches = new Batch[](_limit);
        uint128 currentIndex = head;
        uint256 batchesCount = 0;
        uint256 currentBatchIndex = 0;

        while (currentIndex != tail && batchesCount < _limit) {
            if (currentBatchIndex >= _offset) {
                batches[batchesCount] = csModule.depositQueueItem(
                    queuePriority,
                    currentIndex
                );
                batchesCount++;
            }

            currentIndex = csModule
                .depositQueueItem(queuePriority, currentIndex)
                .next();
            currentBatchIndex++;
        }

        // Trim the array to the actual number of batches
        assembly {
            mstore(batches, batchesCount)
        }

        return batches;
    }
}
