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

import "./base/BaseChainIdMapping.sol";
import "../utils/Utils.sol";
import "../utils/GNSPSBytesLib.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

// https://raw.githubusercontent.com/LayerZero-Labs/sdk/main/packages/lz-sdk/src/enums/ChainId.ts
contract LayerZeroChainIdMapping is BaseChainIdMapping, Ownable2Step {
    constructor(
        uint64[] memory _msgportChainIds,
        bytes[] memory _lowLevelChainIds
    ) BaseChainIdMapping(_msgportChainIds, _lowLevelChainIds) {}

    function addChainIdMap(
        uint64 _msgportChainId,
        bytes memory _lowLevelChainId
    ) external onlyOwner {
        _addChainIdMap(_msgportChainId, _lowLevelChainId);
    }
}
