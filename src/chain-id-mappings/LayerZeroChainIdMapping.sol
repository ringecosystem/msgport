// This file is part of Darwinia.
// Copyright (C) 2018-2022 Darwinia Network
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
contract LayerZeroChainIdMapping {
    error LineRegistryChainIdNotFound(uint256 lineRegistryChainId);
    error LzChainIdNotFound(uint16 lzChainId);

    mapping(uint256 => uint16) public downMapping;
    mapping(uint16 => uint256) public upMapping;

    constructor(uint256[] memory _lineRegistryChainIds, uint16[] memory _lzChainIds) {
        require(_lineRegistryChainIds.length == _lzChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _lineRegistryChainIds.length; i++) {
            _setChainIdMap(_lineRegistryChainIds[i], _lzChainIds[i]);
        }
    }

    function _setChainIdMap(uint256 _lineRegistryChainId, uint16 _lzChainId) internal {
        downMapping[_lineRegistryChainId] = _lzChainId;
        upMapping[_lzChainId] = _lineRegistryChainId;
    }

    function down(uint256 lineRegistryChainId) internal view returns (uint16 lzChainId) {
        lzChainId = downMapping[lineRegistryChainId];
        if (lzChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }

    function up(uint16 lzChainId) internal view returns (uint256 lineRegistryChainId) {
        lineRegistryChainId = upMapping[lzChainId];
        if (lineRegistryChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }
}
