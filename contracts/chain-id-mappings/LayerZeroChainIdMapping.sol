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

pragma solidity >=0.8.9;

import "../interfaces/IChainIdMapping.sol";
import "../utils/Utils.sol";
import "../utils/GNSPSBytesLib.sol";

// https://raw.githubusercontent.com/LayerZero-Labs/sdk/main/packages/lz-sdk/src/enums/ChainId.ts
contract LayerZeroChainIdMapping is IChainIdMapping {
    mapping(uint64 => uint16) public downMapping;
    mapping(uint16 => uint64) public upMapping;

    function setDownMapping(
        uint64[] memory msgportChainIds,
        uint16[] memory lzChainIds
    ) external {
        for (uint i = 0; i < msgportChainIds.length; i++) {
            downMapping[msgportChainIds[i]] = lzChainIds[i];
        }
    }

    function setUpMapping(
        uint16[] memory lzChainIds,
        uint64[] memory msgportChainIds
    ) external {
        for (uint i = 0; i < lzChainIds.length; i++) {
            upMapping[lzChainIds[i]] = msgportChainIds[i];
        }
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
