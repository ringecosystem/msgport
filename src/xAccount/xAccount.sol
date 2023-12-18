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

import "../interfaces/ILineRegistry.sol";
import "../user/Application.sol";

contract xAccount is Application {
    ILineRegistry public immutable REGISTRY;
    uint256 public immutable CHAINID;
    address public immutable OWNER;

    constructor(address registry, uint256 chainId, address owner) {
        REGISTRY = ILineRegistry(registry);
        CHAINID = chainId;
        OWNER = owner;
    }

    receive() external payable {}

    function _checkXAuth() internal virtual {
        address line = _msgLine();
        uint256 fromChainId = _fromChainId();
        require(fromChainId != block.chainid, "!fromChainId");
        require(REGISTRY.isTrustedLine(line), "!line");
        require(fromChainId == CHAINID, "!xOwner");
        require(_xmsgSender() == OWNER, "!xOwner");
    }

    function xOwner() public view returns (uint256, address) {
        return (CHAINID, OWNER);
    }

    /// @dev Executes a low-level operation if the caller is xOwner.
    //
    /// Reverts and bubbles up error if operation fails.
    //
    /// Accounts implementing this interface MUST accept the following operation parameter values:
    /// - 0 = CALL
    /// - 1 = DELEGATECALL
    /// - 2 = CREATE
    /// - 3 = CREATE2
    //
    /// Accounts implementing this interface MAY support additional operations or restrict a signer's
    /// ability to execute certain operations.
    //
    /// @param target    The target address of the operation
    /// @param value     The Ether value to be sent to the target
    /// @param data      The encoded operation calldata
    /// @param operation A value indicating the type of operation to perform
    /// @return The result of the operation
    function execute(address target, uint256 value, bytes calldata data, uint8 operation)
        external
        payable
        returns (bytes memory)
    {
        _checkXAuth();
        require(operation == 0, "!CALL");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        if (!success) {
            _revert(returndata);
        }
        return returndata;
    }

    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert("!execute");
        }
    }
}
