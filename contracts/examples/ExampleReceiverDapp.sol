// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/IMessageReceiver.sol";

contract ExampleReceiverDapp is IMessageReceiver {
    uint256 fromChainId;
    address public fromDappAddress;
    bytes public message;
    uint256 public nonce;

    function recv(
        uint256 _fromChainId,
        address _fromDappAddress,
        bytes calldata _message,
        uint256 _nonce
    ) external {
        fromChainId = _fromChainId;
        fromDappAddress = _fromDappAddress;
        message = _message;
        nonce = _nonce;
    }
}
