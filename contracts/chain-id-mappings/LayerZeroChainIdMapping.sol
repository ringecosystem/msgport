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

import "../interfaces/IChainIdMapping.sol";
import "../utils/Utils.sol";
import "../utils/GNSPSBytesLib.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

// https://raw.githubusercontent.com/LayerZero-Labs/sdk/main/packages/lz-sdk/src/enums/ChainId.ts
contract LayerZeroChainIdMapping is IChainIdMapping, Ownable2Step {
    mapping(uint64 => uint16) public downMapping;
    mapping(uint16 => uint64) public upMapping;

    constructor(
        uint64[] memory _msgportChainIds,
        uint16[] memory _lowLevelChainIds
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

    function addChainIdMap(
        uint64 _msgportChainId,
        uint16 _lowLevelChainId
    ) external onlyOwner {
        require(
            downMapping[_msgportChainId] == 0,
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
        uint16 lzChainId = downMapping[msgportChainId];
        if (lzChainId == 0) {
            revert MsgportChainIdNotFound(msgportChainId);
        }
        lowLevelChainId = Utils.uint16ToBytes(lzChainId);
    }

    function up(
        bytes memory lowLevelChainId
    ) external view returns (uint64 msgportChainId) {
        uint16 lzChainId = Utils.bytesToUint16(lowLevelChainId);
        if (lzChainId == 0) {
            revert LowLevelChainIdNotFound(lowLevelChainId);
        }
        msgportChainId = upMapping[lzChainId];
    }
}
