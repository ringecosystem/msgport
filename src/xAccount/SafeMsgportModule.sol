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

import "../interfaces/ISafe.sol";
import "../user/xAuth.sol";

contract SafeMsgportModule is xAuth {
    address public trustedLine;

    address public immutable CHILD_SAFE_XACCOUNT;
    uint256 public immutable ROOT_CHAINID;
    address public immutable ROOT_OWNER;

    event SetTrustedLine(address line);

    error ModuleTransactionFailed(bytes reason);
    error SendEtherFailed(bytes reason);

    constructor(address xAccount, uint256 chainId, address owner, address line) {
        trustedLine = line;
        CHILD_SAFE_XACCOUNT = xAccount;
        ROOT_CHAINID = chainId;
        ROOT_OWNER = owner;
        emit SetTrustedLine(line);
    }

    /// @dev Fetch the xAccount xOwner.
    /// @return (chainId, owner)
    ///   - chainId Chain id that xAccount belongs in.
    ///   - owner Owner that xAccount belongs to.
    function xOwner() public view override returns (uint256, address) {
        return (ROOT_CHAINID, ROOT_OWNER);
    }

    /// @dev Check the line is trusted or not.
    /// @return Check result.
    function isTrustedLine(address line) public view override returns (bool) {
        return trustedLine == line;
    }

    /// @dev Set trusted line.
    /// @param line New trusted line.
    function setTrustedLine(address line) external {
        _checkXAuth();
        trustedLine = line;
        emit SetTrustedLine(line);
    }

    /// @dev Receive xCall from root chain xOwner.
    /// @param target Target of the transaction that should be executed
    /// @param value Wei value of the transaction that should be executed
    /// @param data Data of the transaction that should be executed
    /// @param operation Operation (Call or Delegatecall) of the transaction that should be executed
    /// @return xExecute return data Return data after xCall.
    function xExecute(address target, uint256 value, bytes calldata data, Operation operation)
        external
        payable
        returns (bytes memory)
    {
        _checkXAuth();
        if (msg.value > 0) {
            (bool s, bytes memory r) = CHILD_SAFE_XACCOUNT.call{value: msg.value}("");
            if (!s) revert SendEtherFailed(r);
        }
        (bool success, bytes memory returnData) =
            ISafe(CHILD_SAFE_XACCOUNT).execTransactionFromModuleReturnData(target, value, data, operation);
        if (!success) revert ModuleTransactionFailed(returnData);
        return returnData;
    }
}
