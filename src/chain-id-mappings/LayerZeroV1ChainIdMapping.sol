// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// https://raw.githubusercontent.com/LayerZero-Labs/sdk/main/packages/lz-sdk/src/enums/ChainId.ts
contract LayerZeroV1ChainIdMapping {
    error ChainIdNotFound(uint16 lzchainId);
    error LzChainIdNotFound(uint256 ChainId);

    mapping(uint256 => uint16) public downMapping;
    mapping(uint16 => uint256) public upMapping;

    event SetChainIdMap(uint256 chainId, uint16 lzChainId);

    constructor(uint256[] memory chainIds, uint16[] memory lzChainIds) {
        require(chainIds.length == lzChainIds.length, "Lengths do not match.");

        uint256 len = chainIds.length;
        for (uint256 i = 0; i < len; i++) {
            _setChainIdMap(chainIds[i], lzChainIds[i]);
        }
    }

    function _setChainIdMap(uint256 chainId, uint16 lzChainId) internal {
        downMapping[chainId] = lzChainId;
        upMapping[lzChainId] = chainId;
        emit SetChainIdMap(chainId, lzChainId);
    }

    function down(uint256 chainId) internal view returns (uint16 lzChainId) {
        lzChainId = downMapping[chainId];
        if (lzChainId == 0) {
            revert LzChainIdNotFound(chainId);
        }
    }

    function up(uint16 lzChainId) internal view returns (uint256 chainId) {
        chainId = upMapping[lzChainId];
        if (chainId == 0) {
            revert ChainIdNotFound(lzChainId);
        }
    }
}
