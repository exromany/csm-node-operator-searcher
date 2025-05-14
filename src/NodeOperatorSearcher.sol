// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./interfaces/ICSModule.sol";

contract NodeOperatorSearcher {
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

            if (_searchMode != SearchMode.PROPOSED_ADDRESSES) {
                matched = (operator.managerAddress == _addressToSearch ||
                    operator.rewardAddress == _addressToSearch);
            }

            if (!matched && (_searchMode != SearchMode.CURRENT_ADDRESSES)) {
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
}
