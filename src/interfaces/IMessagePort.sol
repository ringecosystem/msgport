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

interface IMessagePort {
    event MessageSuccess(bytes returnData);
    event MessageFailure(bytes errorData);

    /// @dev Send a cross-chain message over the MessagePort.
    /// @notice Send a cross-chain message over the MessagePort.
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params) external payable;

    /// @notice Get a quote in source native gas, for the amount that send() requires to pay for message delivery.
    ///         It should be noted that not all ports will implement this interface.
    /// @dev If the messaging protocol does not support on-chain fetch fee, then revert with "Unimplemented!".
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        returns (uint256);
}
