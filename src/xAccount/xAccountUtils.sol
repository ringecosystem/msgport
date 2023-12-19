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

import "@openzeppelin/contracts/utils/Address.sol";

library xAccountUtils {
    event Upgraded(address indexed implementation);

    struct xOwnerSlot {
        uint96 chainId;
        address owner;
    }

    struct AddressSlot {
        address value;
    }

    // This is the keccak-256 hash of "xAccount.proxy.xOwner" subtracted by 1
    bytes32 internal constant XOWNER_SLOT = 0x9868bf934eaff5d07f0b6c8cbc0df1cb18f917abf4b13cabd52e1f349c64a235;

    error ERC1967InvalidImplementation(address implementation);
    error ERC1967NonPayable();
    error xAcountChainIdOverflow();

    function _getXOwner() internal view returns (uint256, address) {
        xOwnerSlot storage x = _getXOwnerSlot(XOWNER_SLOT);
        return (uint256(x.chainId), x.owner);
    }

    function _setXOwner(uint256 chainId, address owner_) internal {
        if (chainId > type(uint96).max) {
            revert xAcountChainIdOverflow();
        }
        xOwnerSlot storage x = _getXOwnerSlot(XOWNER_SLOT);
        x.chainId = uint96(chainId);
        x.owner = owner_;
    }

    function _getXOwnerSlot(bytes32 slot) internal pure returns (xOwnerSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    function _getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    // This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1.
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function getImplementation() internal view returns (address) {
        return _getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert ERC1967InvalidImplementation(newImplementation);
        }
        _getAddressSlot(IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);

        if (data.length > 0) {
            Address.functionDelegateCall(newImplementation, data);
        } else {
            _checkNonPayable();
        }
    }

    function _checkNonPayable() private {
        if (msg.value > 0) {
            revert ERC1967NonPayable();
        }
    }
}
