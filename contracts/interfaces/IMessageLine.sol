// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageLine {
    event MessageSent(
        bytes32 indexed _messageId,
        uint64 _fromChainId,
        uint64 _toChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes _message,
        bytes _params,
        address _fromLineAddress
    );

    event MessageReceived(bytes32 indexed _messageId, address _toLineAddress);

    event ReceiverError(bytes32 indexed _messageId, string _reason, address _toLineAddress);

    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) external payable;

    function estimateFee(
        uint64 _toChainId, // Dest lineRegistry chainId
        bytes calldata _payload,
        bytes calldata _params
    ) external view returns (uint256);
}
