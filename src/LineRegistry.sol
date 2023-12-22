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
import "./interfaces/ILineMetadata.sol";

/// @title LineRegistry
/// @notice LineRegistry will be deployed on each chain.
/// - Could be used to verify whether the line has been registered.
/// - Lines that be audited by MsgDAO is marked as `trusted`.
contract LineRegistry is Ownable2Step {
    event AddLine(string name, address line);
    event MarkLine(string name, bool flag);

    /// @dev All line names in registry
    string[] private _names;
    /// @dev lineName => lineAddress
    mapping(string => address) private _lineLookup;
    /// @dev lineAddress => trusted
    mapping(address => bool) private _lines;

    constructor(address dao) {
        _transferOwnership(dao);
    }

    /// @dev Return all line count.
    function count() public view returns (uint256) {
        return _names.length;
    }

    /// @dev Return all line names.
    function list() public view returns (string[] memory) {
        return _names;
    }

    /// @dev Fetch line address by line name.
    function getLine(string calldata name) external view returns (address) {
        return _lineLookup[name];
    }

    /// @dev Add a line.
    /// @notice Revert if the line name is existed.
    function addLine(address line) external onlyOwner {
        string memory name = ILineMetadata(line).name();
        require(_lineLookup[name] == address(0), "already exist");
        _names.push(name);
        _lineLookup[name] = line;
        _markLine(line, true);
        emit AddLine(name, line);
    }

    /// @dev Mark the line to be trusted or not.
    /// @notice Revert if the line name is not exist.
    function markLine(string calldata name, bool flag) external onlyOwner {
        address line = _lineLookup[name];
        require(line != address(0), "!exist");
        _markLine(line, flag);
        emit MarkLine(name, flag);
    }

    function _markLine(address line, bool flag) internal {
        _lines[line] = flag;
    }

    /// @dev Query if the line is trusted by MsgDAO.
    function isTrustedLine(address line) external view returns (bool) {
        return _lines[line];
    }
}
