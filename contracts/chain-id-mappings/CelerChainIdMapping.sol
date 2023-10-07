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

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract CelerChainIdMapping is Ownable2Step {
    error MsgportChainIdNotFound(uint64 msgportChainId);
    error CelerChainIdNotFound(uint64 celerChainId);

    mapping(uint64 => uint64) public downMapping;
    mapping(uint64 => uint64) public upMapping;

    constructor(uint64[] memory _msgportChainIds, uint64[] memory _celerChainIds) {
        require(_msgportChainIds.length == _celerChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _msgportChainIds.length; i++) {
            downMapping[_msgportChainIds[i]] = _celerChainIds[i];
            upMapping[_celerChainIds[i]] = _msgportChainIds[i];
        }
    }

    function addChainIdMap(uint64 _msgportChainId, uint64 _celerChainId) external onlyOwner {
        require(downMapping[_msgportChainId] == 0, "MsgportChainId already exists.");
        require(upMapping[_celerChainId] == 0, "celerChainId already exists.");
        downMapping[_msgportChainId] = _celerChainId;
        upMapping[_celerChainId] = _msgportChainId;
    }

    function down(uint64 msgportChainId) external view returns (uint64 celerChainId) {
        celerChainId = downMapping[msgportChainId];
        if (celerChainId == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
    }

    function up(uint64 celerChainId) external view returns (uint64 msgportChainId) {
        msgportChainId = upMapping[celerChainId];
        if (msgportChainId == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
    }
}
