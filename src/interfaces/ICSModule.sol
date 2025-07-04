// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// Batch is an uint256 as it's the internal data type used by solidity.
// Batch is a packed value, consisting of the following fields:
//    - uint64  nodeOperatorId
//    - uint64  keysCount -- count of keys enqueued by the batch
//    - uint128 next -- index of the next batch in the queue
type Batch is uint256;

/// @dev Syntactic sugar for the type.
function unwrap(Batch self) pure returns (uint256) {
    return Batch.unwrap(self);
}

function noId(Batch self) pure returns (uint64 n) {
    assembly {
        n := shr(192, self)
    }
}

function keys(Batch self) pure returns (uint64 n) {
    assembly {
        n := shl(64, self)
        n := shr(192, n)
    }
}

function next(Batch self) pure returns (uint128 n) {
    assembly {
        n := shl(128, self)
        n := shr(128, n)
    }
}

using {noId, keys, next, unwrap} for Batch global;

interface ICSModule {
    struct NodeOperator {
        uint32 totalAddedKeys;
        uint32 totalWithdrawnKeys;
        uint32 totalDepositedKeys;
        uint32 totalVettedKeys;
        uint32 stuckValidatorsCount;
        uint32 depositableValidatorsCount;
        uint32 targetLimit;
        uint8 targetLimitMode;
        uint32 totalExitedKeys;
        uint32 enqueuedCount;
        address managerAddress;
        address proposedManagerAddress;
        address rewardAddress;
        address proposedRewardAddress;
        bool extendedManagerPermissions;
        bool usedPriorityQueue;
    }

    struct NodeOperatorManagementProperties {
        address managerAddress;
        address rewardAddress;
        bool extendedManagerPermissions;
    }

    // type Batch is uint256;

    function getNodeOperator(
        uint256 nodeOperatorId
    ) external view returns (NodeOperator memory);

    function getNodeOperatorManagementProperties(
        uint256 nodeOperatorId
    ) external view returns (NodeOperatorManagementProperties memory);

    function getNodeOperatorsCount() external view returns (uint256);

    /// @dev QUEUE_LOWEST_PRIORITY identifies the range of available priorities: [0; QUEUE_LOWEST_PRIORITY].
    function QUEUE_LOWEST_PRIORITY() external view returns (uint256);

    function depositQueuePointers(
        uint256 queuePriority
    ) external view returns (uint128 head, uint128 tail);

    function depositQueueItem(
        uint256 queuePriority,
        uint128 index
    ) external view returns (Batch);
}
