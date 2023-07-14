// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../interfaces/IMessageReceiver.sol";

contract ExampleReceiverDapp is IMessageReceiver {
    uint256 public fromChainId;
    address public localLineAddress;
    address public fromDappAddress;
    bytes public message;

    function recv(
        uint256 _fromChainId,
        address _fromDappAddress,
        address _localLineAddress,
        bytes calldata _message
    ) external {
        fromChainId = _fromChainId;
        localLineAddress = _localLineAddress;
        fromDappAddress = _fromDappAddress;
        message = _message;
    }
}
