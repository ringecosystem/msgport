// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageLine {
    event MessageSent(
        bytes32 indexed _messageId,
        uint64 _fromChainId,
        uint64 _toChainId,
        address _fromDapp,
        address _toDapp,
        bytes _message,
        bytes _params,
        address _fromLine
    );

    event MessageReceived(bytes32 indexed _messageId, address _toLine);

    event ReceiverError(bytes32 indexed _messageId, bytes _reason, address _toLine);

    function send(uint64 _toChainId, address _toDapp, bytes memory _payload, bytes memory _params) external payable;

    function estimateFee(
        uint64 _toChainId, // Dest lineRegistry chainId
        bytes calldata _payload,
        bytes calldata _params
    ) external view returns (uint256);
}
