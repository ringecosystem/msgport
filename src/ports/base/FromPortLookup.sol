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

abstract contract FromPortLookup {
    event SetFromPort(uint256 fromChainId, address fromPort);

    // fromChainId => fromPortAddress
    mapping(uint256 => address) public fromPortLookup;

    function _setFromPort(uint256 fromChainId, address fromPort) internal virtual {
        fromPortLookup[fromChainId] = fromPort;
        emit SetFromPort(fromChainId, fromPort);
    }

    function _fromPort(uint256 fromChainId) internal view returns (address) {
        return fromPortLookup[fromChainId];
    }

    function _checkedFromPort(uint256 fromChainId) internal view returns (address l) {
        l = fromPortLookup[fromChainId];
        require(l != address(0), "!fromPort");
    }
}
