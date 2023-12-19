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

import "@openzeppelin/contracts/utils/StorageSlot.sol";

library xAccountUtils {
    struct xOwnerSlot {
        uint96 chainId;
        address owner;
    }

    // This is the keccak-256 hash of "xAccount.proxy.xOwner" subtracted by 1
    bytes32 private constant _XOWNER_SLOT = 0x9868bf934eaff5d07f0b6c8cbc0df1cb18f917abf4b13cabd52e1f349c64a235;

    function _getXOwner() internal view returns (uint256, address) {
        xOwnerSlot storage x = _getXOwnerSlot(_XOWNER_SLOT);
        return (uint256(x.chainId), x.owner);
    }

    function _setXOwner(uint256 chainId, address owner_) internal {
        require(chainId <= type(uint96).max, "!overflow");
        xOwnerSlot storage x = _getXOwnerSlot(_XOWNER_SLOT);
        x.chainId = uint96(chainId);
        x.owner = owner_;
    }

    function _getXOwnerSlot(bytes32 slot) internal pure returns (xOwnerSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}
