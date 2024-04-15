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

import "./FromPortLookup.sol";
import "./ToPortLookup.sol";

abstract contract PeerLookup {
    // chainId => peer
    mapping(uint256 => address) internal _peers;

    event PeerSet(uint256 chainId, address peer);

    function peerOf(uint256 chainId) public virtual returns (address) {
        return _peers[chainId];
    }

    function _setPeer(uint256 chainId, address peer) internal virtual {
        _peers[chainId] = peer;
        emit PeerSet(chainId, peer);
    }

    function _checkedPeer(uint256 chainId) internal view virtual returns (address p) {
        p = _peers[chainId];
        require(p != address(0), "!peer");
    }
}
