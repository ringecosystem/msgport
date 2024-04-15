// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

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
