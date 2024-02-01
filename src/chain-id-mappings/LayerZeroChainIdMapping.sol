// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
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

// https://raw.githubusercontent.com/LayerZero-Labs/sdk/main/packages/lz-sdk/src/enums/ChainId.ts
contract LayerZeroChainIdMapping {
    error PortRegistryChainIdNotFound(uint256 portRegistryChainId);
    error LzChainIdNotFound(uint16 lzChainId);

    mapping(uint256 => uint16) public downMapping;
    mapping(uint16 => uint256) public upMapping;

    constructor(uint256[] memory _portRegistryChainIds, uint16[] memory _lzChainIds) {
        require(_portRegistryChainIds.length == _lzChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _portRegistryChainIds.length; i++) {
            _setChainIdMap(_portRegistryChainIds[i], _lzChainIds[i]);
        }
    }

    function _setChainIdMap(uint256 _portRegistryChainId, uint16 _lzChainId) internal {
        downMapping[_portRegistryChainId] = _lzChainId;
        upMapping[_lzChainId] = _portRegistryChainId;
    }

    function down(uint256 portRegistryChainId) internal view returns (uint16 lzChainId) {
        lzChainId = downMapping[portRegistryChainId];
        if (lzChainId == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }

    function up(uint16 lzChainId) internal view returns (uint256 portRegistryChainId) {
        portRegistryChainId = upMapping[lzChainId];
        if (portRegistryChainId == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }
}
