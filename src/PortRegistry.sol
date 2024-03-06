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

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/// @title PortRegistry
/// @notice PortRegistry will be deployed on each chain.
/// - Could be used to verify whether the port has been registered.
/// - Ports that be audited by MsgDAO is marked as `trusted`.
contract PortRegistry is Initializable, Ownable2Step, UUPSUpgradeable {
    event SetPort(uint256 chainId, string name, address port);
    event DeletePort(uint256 chainId, string name, address port);

    // chainId => name => port
    mapping(uint256 => mapping(string => address)) private _portLookup;
    // chainId => port => name
    mapping(uint256 => mapping(address => string)) private _nameLookup;

    function initialize(address dao) public initializer {
        _transferOwnership(dao);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /// @dev Fetch port address by chainId and name.
    function get(uint256 chainId, string calldata name) external view returns (address) {
        return _portLookup[chainId][name];
    }

    /// @dev Fetch port name by chainId and port address.
    function get(uint256 chainId, address port) external view returns (string memory) {
        return _nameLookup[chainId][port];
    }

    /// @dev Set a port.
    function set(uint256 chainId, string calldata name, address port) external onlyOwner {
        require(bytes(name).length > 0, "!name");
        require(port != address(0), "!port");
        _portLookup[chainId][name] = port;
        _nameLookup[chainId][port] = name;
        emit SetPort(chainId, name, port);
    }

    /// @dev Delete a port.
    function del(uint256 chainId, string calldata name, address port) external onlyOwner {
        delete _portLookup[chainId][name];
        delete _nameLookup[chainId][port];
        emit DeletePort(chainId, name, port);
    }
}
