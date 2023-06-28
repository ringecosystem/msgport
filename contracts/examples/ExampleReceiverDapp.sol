// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../interfaces/IMessageReceiver.sol";

contract ExampleReceiverDapp is IMessageReceiver {
    uint256 public fromChainId;
    address public fromDappAddress;
    bytes public message;

    function recv(
        uint256 _fromChainId,
        address _fromDappAddress,
        bytes calldata _message
    ) external {
        fromChainId = _fromChainId;
        fromDappAddress = _fromDappAddress;
        message = _message;
    }
}
