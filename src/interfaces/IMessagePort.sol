// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessagePort {
    event MessageSent(
        bytes32 indexed msgId, address fromDapp, uint256 toChainId, address toDapp, bytes message, bytes params
    );
    event MessageRecv(bytes32 indexed msgId, bool result, bytes returnData);

    /// @dev Send a cross-chain message over the MessagePort.
    /// @notice Send a cross-chain message over the MessagePort.
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    /// @return msgId Return the ID of message.
    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        payable
        returns (bytes32 msgId);

    /// @notice Get a quote in source native gas, for the amount that send() requires to pay for message delivery.
    ///         It should be noted that not all ports will implement this interface.
    /// @dev If the messaging protocol does not support on-chain fetch fee, then revert with "Unimplemented!".
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param fromDapp The user application contract address which send the message.
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    function fee(uint256 toChainId, address fromDapp, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        returns (uint256);
}
