// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LayerZeroV2ChainIdMapping {
    error ChainIdNotFound(uint32 endpointId);
    error EndpointIdNotFound(uint256 chainId);

    mapping(uint256 => uint32) public downMapping;
    mapping(uint32 => uint256) public upMapping;

    event SetChainIdMap(uint256 chainId, uint32 endpointId);

    constructor(uint256[] memory chainIds, uint32[] memory endpointIds) {
        require(chainIds.length == endpointIds.length, "Lengths do not match.");

        uint256 len = chainIds.length;
        for (uint256 i = 0; i < len; i++) {
            _setChainIdMap(chainIds[i], endpointIds[i]);
        }
    }

    function _setChainIdMap(uint256 chainId, uint32 endpointId) internal {
        downMapping[chainId] = endpointId;
        upMapping[endpointId] = chainId;
        emit SetChainIdMap(chainId, endpointId);
    }

    function down(uint256 chainId) internal view returns (uint32 endpointId) {
        endpointId = downMapping[chainId];
        if (endpointId == 0) {
            revert EndpointIdNotFound(chainId);
        }
    }

    function up(uint32 endpointId) internal view returns (uint256 chainId) {
        chainId = upMapping[endpointId];
        if (chainId == 0) {
            revert ChainIdNotFound(endpointId);
        }
    }
}
