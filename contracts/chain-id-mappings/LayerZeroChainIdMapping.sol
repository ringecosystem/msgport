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

import "@openzeppelin/contracts/access/Ownable2Step.sol";

// https://raw.githubusercontent.com/LayerZero-Labs/sdk/main/packages/lz-sdk/src/enums/ChainId.ts
contract LayerZeroChainIdMapping is Ownable2Step {
    error LineRegistryChainIdNotFound(uint64 lineRegistryChainId);
    error LzChainIdNotFound(uint16 lzChainId);

    mapping(uint64 => uint16) public downMapping;
    mapping(uint16 => uint64) public upMapping;

    constructor(uint64[] memory _lineRegistryChainIds, uint16[] memory _lzChainIds) {
        require(
            _lineRegistryChainIds.length == _lzChainIds.length,
            "Lengths do not match."
        );

        for (uint i = 0; i < _lineRegistryChainIds.length; i++) {
            downMapping[_lineRegistryChainIds[i]] = _lzChainIds[i];
            upMapping[_lzChainIds[i]] = _lineRegistryChainIds[i];
        }
    }

    function addChainIdMap(
        uint64 _lineRegistryChainId,
        uint16 _lzChainId
    ) external onlyOwner {
        require(
            downMapping[_lineRegistryChainId] == 0,
            "LineRegistryChainId already exists."
        );
        require(upMapping[_lzChainId] == 0, "lzChainId already exists.");
        downMapping[_lineRegistryChainId] = _lzChainId;
        upMapping[_lzChainId] = _lineRegistryChainId;
    }

    function down(
        uint64 lineRegistryChainId
    ) external view returns (uint16 lzChainId) {
        lzChainId = downMapping[lineRegistryChainId];
        if (lzChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }

    function up(
        uint16 lzChainId
    ) external view returns (uint64 lineRegistryChainId) {
        lineRegistryChainId = upMapping[lzChainId];
        if (lineRegistryChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }
}
