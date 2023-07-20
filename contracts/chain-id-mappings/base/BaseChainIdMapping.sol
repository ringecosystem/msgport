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

import "../../interfaces/IChainIdMapping.sol";
import "../../utils/Utils.sol";
import "../../utils/GNSPSBytesLib.sol";

abstract contract BaseChainIdMapping is IChainIdMapping {
    mapping(uint64 => bytes) public downMapping;
    mapping(bytes => uint64) public upMapping;

    constructor(
        uint64[] memory _msgportChainIds,
        bytes[] memory _lowLevelChainIds
    ) {
        require(
            _msgportChainIds.length == _lowLevelChainIds.length,
            "Lengths do not match."
        );

        for (uint i = 0; i < _msgportChainIds.length; i++) {
            downMapping[_msgportChainIds[i]] = _lowLevelChainIds[i];
            upMapping[_lowLevelChainIds[i]] = _msgportChainIds[i];
        }
    }

    function _addChainIdMap(
        uint64 _msgportChainId,
        bytes memory _lowLevelChainId
    ) internal virtual {
        require(
            downMapping[_msgportChainId].length == 0,
            "MsgportChainId already exists."
        );
        require(
            upMapping[_lowLevelChainId] == 0,
            "LowLevelChainId already exists."
        );
        downMapping[_msgportChainId] = _lowLevelChainId;
        upMapping[_lowLevelChainId] = _msgportChainId;
    }

    function down(
        uint64 msgportChainId
    ) external view returns (bytes memory lowLevelChainId) {
        lowLevelChainId = downMapping[msgportChainId];
        if (lowLevelChainId.length == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
    }

    function up(
        bytes memory lowLevelChainId
    ) external view returns (uint64 msgportChainId) {
        msgportChainId = upMapping[lowLevelChainId];
        if (msgportChainId == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
    }
}
