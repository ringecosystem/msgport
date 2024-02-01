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

contract AxelarChainIdMapping {
    error PortRegistryChainIdNotFound(uint256 portRegistryChainId);
    error AxelarChainIdNotFound(string axelarChainId);

    mapping(uint256 => string) public downMapping;
    mapping(string => uint256) public upMapping;

    constructor(uint256[] memory _portRegistryChainIds, string[] memory _axelarChainIds) {
        require(_portRegistryChainIds.length == _axelarChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _portRegistryChainIds.length; i++) {
            _setChainIdMap(_portRegistryChainIds[i], _axelarChainIds[i]);
        }
    }

    function _setChainIdMap(uint256 _portRegistryChainId, string memory _axelarChainId) internal {
        downMapping[_portRegistryChainId] = _axelarChainId;
        upMapping[_axelarChainId] = _portRegistryChainId;
    }

    function down(uint256 portRegistryChainId) internal view returns (string memory axelarChainId) {
        axelarChainId = downMapping[portRegistryChainId];
        if (bytes(axelarChainId).length == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }

    function up(string memory axelarChainId) internal view returns (uint256 portRegistryChainId) {
        portRegistryChainId = upMapping[axelarChainId];
        if (portRegistryChainId == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }
}
