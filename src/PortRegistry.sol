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

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/// @title PortRegistry
/// @notice PortRegistry will be deployed on each chain.
/// - Could be used to verify whether the port has been registered.
/// - Ports that be audited by MsgDAO is marked as `trusted`.
contract PortRegistry is Initializable, Ownable2Step, UUPSUpgradeable {
    event SetPort(uint256 chainId, bytes4 code, address port);
    event DeletePort(uint256 chainId, bytes4 code, address port);

    mapping(uint256 chainId => mapping(bytes4 code => address port)) private _portLookup;
    mapping(uint256 chainId => mapping(address port => bytes4 code)) private _codeLookup;

    function initialize(address dao) public initializer {
        _transferOwnership(dao);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /// @dev Fetch port address by chainId and port code.
    function get(uint256 chainId, bytes4 code) external view returns (address) {
        return _portLookup[chainId][code];
    }

    /// @dev Fetch port code by chainId and port address.
    function get(uint256 chainId, address port) external view returns (bytes4) {
        return _codeLookup[chainId][port];
    }

    /// @dev Set a port.
    function set(uint256 chainId, bytes4 code, address port) external onlyOwner {
        require(code != bytes4(0), "!code");
        require(port != address(0), "!port");
        _portLookup[chainId][code] = port;
        _codeLookup[chainId][port] = code;
        emit SetPort(chainId, code, port);
    }

    /// @dev Delete a port.
    function del(uint256 chainId, bytes4 code, address port) external onlyOwner {
        delete _portLookup[chainId][code];
        delete _codeLookup[chainId][port];
        emit DeletePort(chainId, code, port);
    }
}
