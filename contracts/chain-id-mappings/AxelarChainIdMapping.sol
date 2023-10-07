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
    error MsgportChainIdNotFound(uint64 msgportChainId);
    error AxelarChainIdNotFound(string axelarChainId);

    mapping(uint64 => string) public downMapping;
    mapping(string => uint64) public upMapping;

    constructor(uint64[] memory _msgportChainIds, string[] memory _axelarChainIds) {
        require(_msgportChainIds.length == _axelarChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _msgportChainIds.length; i++) {
            downMapping[_msgportChainIds[i]] = _axelarChainIds[i];
            upMapping[_axelarChainIds[i]] = _msgportChainIds[i];
        }
    }

    function addChainIdMap(uint64 _msgportChainId, string memory _axelarChainId) external onlyOwner {
        require(bytes(downMapping[_msgportChainId]).length == 0, "MsgportChainId already exists.");
        require(upMapping[_axelarChainId] == 0, "axelarChainId already exists.");
        downMapping[_msgportChainId] = _axelarChainId;
        upMapping[_axelarChainId] = _msgportChainId;
    }

    function down(uint64 msgportChainId) external view returns (string memory axelarChainId) {
        axelarChainId = downMapping[msgportChainId];
        if (bytes(axelarChainId).length == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
    }

    function up(string memory axelarChainId) external view returns (uint64 msgportChainId) {
        msgportChainId = upMapping[axelarChainId];
        if (msgportChainId == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
    }
}
