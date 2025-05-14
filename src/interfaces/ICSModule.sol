// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

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
    }

    function getNodeOperator(
        uint256 nodeOperatorId
    ) external view returns (NodeOperator memory);

    function getNodeOperatorsCount() external view returns (uint256);
}
