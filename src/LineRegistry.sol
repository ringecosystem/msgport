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
///         It is the registry of messageLine and can be used to verify whether the line has been registered.
contract LineRegistry is Ownable2Step {
    event AddLine(string name, address line);

    string[] public _names;
    // lineName => lineAddress
    mapping(string => address) private _lineLookup;

    constructor(address dao) {
        _transferOwnership(dao);
    }

    function count() public view returns (uint256) {
        return _names.length;
    }

    function list() public view returns (string[] memory) {
        return _names;
    }

    function getLine(string calldata name) external view returns (address) {
        return _lineLookup[name];
    }

    function addLine(address line) external onlyOwner {
        string memory name = ILineMetadata(line).name();
        require(_lineLookup[name] == address(0), "Line name already exists");
        _lineLookup[name] = line;
        emit AddLine(name, line);
    }
}
