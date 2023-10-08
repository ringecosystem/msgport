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

contract AxelarChainIdMapping is Ownable2Step {
    error LineRegistryChainIdNotFound(uint64 lineRegistryChainId);
    error AxelarChainIdNotFound(string axelarChainId);

    mapping(uint64 => string) public downMapping;
    mapping(string => uint64) public upMapping;

    constructor(uint64[] memory _lineRegistryChainIds, string[] memory _axelarChainIds) {
        require(_lineRegistryChainIds.length == _axelarChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _lineRegistryChainIds.length; i++) {
            downMapping[_lineRegistryChainIds[i]] = _axelarChainIds[i];
            upMapping[_axelarChainIds[i]] = _lineRegistryChainIds[i];
        }
    }

    function addChainIdMap(uint64 _lineRegistryChainId, string memory _axelarChainId) external onlyOwner {
        require(bytes(downMapping[_lineRegistryChainId]).length == 0, "LineRegistryChainId already exists.");
        require(upMapping[_axelarChainId] == 0, "axelarChainId already exists.");
        downMapping[_lineRegistryChainId] = _axelarChainId;
        upMapping[_axelarChainId] = _lineRegistryChainId;
    }

    function down(uint64 lineRegistryChainId) public view returns (string memory axelarChainId) {
        axelarChainId = downMapping[lineRegistryChainId];
        if (bytes(axelarChainId).length == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }

    function up(string memory axelarChainId) public view returns (uint64 lineRegistryChainId) {
        lineRegistryChainId = upMapping[axelarChainId];
        if (lineRegistryChainId == 0) {
            revert LineRegistryChainIdNotFound(lineRegistryChainId);
        }
    }
}
