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

pragma solidity ^0.8.9;

contract CelerChainIdMapping {
    error LineRegistryChainIdNotFound(uint64 lineRegistryChainId);
    error CelerChainIdNotFound(uint64 celerChainId);

    mapping(uint64 => uint64) public downMapping;
    mapping(uint64 => uint64) public upMapping;

    constructor(uint64[] memory _lineRegistryChainIds, uint64[] memory _celerChainIds) {
        require(_lineRegistryChainIds.length == _celerChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _lineRegistryChainIds.length; i++) {
            downMapping[_lineRegistryChainIds[i]] = _celerChainIds[i];
            upMapping[_celerChainIds[i]] = _lineRegistryChainIds[i];
        }
    }

    function _addChainIdMap(uint64 _lineRegistryChainId, uint64 _celerChainId) internal {
        require(downMapping[_lineRegistryChainId] == 0, "LineRegistryChainId already exists.");
        require(upMapping[_celerChainId] == 0, "celerChainId already exists.");
        downMapping[_lineRegistryChainId] = _celerChainId;
        upMapping[_celerChainId] = _lineRegistryChainId;
    }

    function down(uint64 lineRegistryChainId) internal view returns (uint64 celerChainId) {
        celerChainId = downMapping[lineRegistryChainId];
        if (celerChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }

    function up(uint64 celerChainId) internal view returns (uint64 lineRegistryChainId) {
        lineRegistryChainId = upMapping[celerChainId];
        if (lineRegistryChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }
}
