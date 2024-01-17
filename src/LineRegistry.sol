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

/// @title LineRegistry
/// @notice LineRegistry will be deployed on each chain.
/// - Could be used to verify whether the line has been registered.
/// - Lines that be audited by MsgDAO is marked as `trusted`.
contract LineRegistry is Ownable2Step {
    event SetLine(uint256 chainId, bytes4 code, address line);
    event DeleteLine(uint256 chainId, bytes4 code, address line);

    mapping(uint256 chainId => mapping(bytes4 code => address line)) private _lineLookup;
    mapping(uint256 chainId => mapping(address line => bytes4 code)) private _codeLookup;

    constructor(address dao) {
        _transferOwnership(dao);
    }

    /// @dev Fetch line address by chainId and line code.
    function get(uint256 chainId, bytes4 code) external view returns (address) {
        return _lineLookup[chainId][code];
    }

    /// @dev Fetch line code by chainId and line address.
    function get(uint256 chainId, address line) external view returns (bytes4) {
        return _codeLookup[chainId][line];
    }

    /// @dev Set a line.
    function set(uint256 chainId, bytes4 code, address line) external onlyOwner {
        require(code != bytes4(0), "!code");
        require(line != address(0), "!line");
        _lineLookup[chainId][code] = line;
        _codeLookup[chainId][line] = code;
        emit SetLine(chainId, code, line);
    }

    /// @dev Delete a line.
    function del(uint256 chainId, bytes4 code, address line) external onlyOwner {
        delete _lineLookup[chainId][code];
        delete _codeLookup[chainId][line];
        emit DeleteLine(chainId, code, line);
    }
}
