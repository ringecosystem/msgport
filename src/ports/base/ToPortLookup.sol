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

pragma solidity ^0.8.0;

abstract contract ToPortLookup {
    event SetToPort(uint256 toChainId, address toPort);

    // toChainId => toPortAddress
    mapping(uint256 => address) internal _toPortLookup;

    function toPortLookup(uint256 toChainId) public view virtual returns (address) {
        return _toPortLookup[toChainId];
    }

    function _setToPort(uint256 toChainId, address toPort) internal virtual {
        _toPortLookup[toChainId] = toPort;
        emit SetToPort(toChainId, toPort);
    }

    function _toPort(uint256 toChainId) internal view returns (address) {
        return _toPortLookup[toChainId];
    }

    function _checkedToPort(uint256 toChainId) internal view returns (address l) {
        l = _toPortLookup[toChainId];
        require(l != address(0), "!toPort");
    }
}
