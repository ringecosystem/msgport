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

contract LayerZeroChainIdMapping is IChainIdMapping {
    function down(
        uint256 msgportChainId
    ) external pure returns (bytes memory lowLevelChainId) {
        if (msgportChainId == 4002) {
            return Utils.uint16ToBytes(10112);
        } else if (msgportChainId == 1287) {
            return Utils.uint16ToBytes(10126);
        } else if (msgportChainId == 97) {
            return Utils.uint16ToBytes(10102);
        } else {
            revert("LayerZeroChainIdMapping: unknown msgport chain id");
        }
    }

    function up(
        bytes memory lowLevelChainId
    ) external pure returns (uint256 msgportChainId) {
        uint16 lzChainId = Utils.bytesToUint16(lowLevelChainId);
        if (lzChainId == 10112) {
            return 4002;
        } else if (lzChainId == 10126) {
            return 1287;
        } else if (lzChainId == 10102) {
            return 97;
        } else {
            revert("LayerZeroChainIdMapping: unknown low level chain id");
        }
    }
}
