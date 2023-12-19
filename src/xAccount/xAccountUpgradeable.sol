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

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "./xAccount.sol";
import "./xAccountUtils.sol";

interface IERC1822Proxiable {
    function proxiableUUID() external view returns (bytes32);
}

contract xAccountUpgradeable is Initializable, xAccount {
    address private immutable __self = address(this);
    string public constant UPGRADE_INTERFACE_VERSION = "5.0.0";

    error UUPSUnauthorizedCallContext();
    error UUPSUnsupportedProxiableUUID(bytes32 slot);

    constructor(address registry) xAccount(registry) {}

    function initialize(address logic) public initializer {
        _upgradeToAndCallUUPS(logic, new bytes(0));
    }

    function _authorizeUpgrade(address) internal virtual {
        _checkXAuth();
    }

    modifier onlyProxy() {
        _checkProxy();
        _;
    }

    modifier notDelegated() {
        _checkNotDelegated();
        _;
    }

    function proxiableUUID() external view virtual notDelegated returns (bytes32) {
        return xAccountUtils.IMPLEMENTATION_SLOT;
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data);
    }

    function _checkProxy() internal view virtual {
        if (address(this) == __self || xAccountUtils.getImplementation() != __self) {
            revert UUPSUnauthorizedCallContext();
        }
    }

    function _checkNotDelegated() internal view virtual {
        if (address(this) != __self) {
            revert UUPSUnauthorizedCallContext();
        }
    }

    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data) private {
        try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
            if (slot != xAccountUtils.IMPLEMENTATION_SLOT) {
                revert UUPSUnsupportedProxiableUUID(slot);
            }
            xAccountUtils.upgradeToAndCall(newImplementation, data);
        } catch {
            revert xAccountUtils.ERC1967InvalidImplementation(newImplementation);
        }
    }
}
