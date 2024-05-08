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

pragma solidity ^0.8.0;

import "../../interfaces/IMessagePort.sol";
import "./PortMetadata.sol";

abstract contract BaseMessagePort is IMessagePort, PortMetadata {
    constructor(string memory name) PortMetadata(name) {}

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    /// @dev Send a cross-chain message over the MessagePort.
    ///      Port developer should implement this, then it will be called by `send`.
    /// @param fromDapp The real sender account who send the message.
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    /// @return msgId Return the ID of message.
    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        virtual
        returns (bytes32 msgId);

    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        public
        payable
        returns (bytes32 msgId)
    {
        msgId = _send(msg.sender, toChainId, toDapp, message, params);
        emit MessageSent(msgId, msg.sender, toChainId, toDapp, message, params);
    }

    /// @dev Make toDapp accept messages.
    ///      This should be called by message port when a message is received.
    /// @param msgId The ID of message.
    /// @param fromChainId The source chainId, standard evm chainId.
    /// @param fromDapp The message sender in source chain.
    /// @param toDapp The message receiver in dest chain.
    /// @param message The message body.
    function _recv(bytes32 msgId, uint256 fromChainId, address fromDapp, address toDapp, bytes memory message)
        internal
    {
        (bool success, bytes memory returndata) =
            toDapp.call{value: msg.value}(abi.encodePacked(message, msgId, fromChainId, fromDapp));
        emit MessageRecv(msgId, success, returndata);
    }

    function fee(uint256, address, address, bytes calldata, bytes calldata) external view virtual returns (uint256) {
        revert("Unimplemented!");
    }
}
