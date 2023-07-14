// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../interfaces/IMessageReceiver.sol";
import "../interfaces/IMessageLine.sol";

contract ExampleReceiverDapp is IMessageReceiver {
    uint256 public fromChainId;
    address public fromLineAddress;
    address public fromDappAddress;
    bytes public message;
    string public lineInfo;

    function recv(
        uint256 _fromChainId,
        address _fromLineAddress,
        address _fromDappAddress,
        bytes calldata _message
    ) external {
        fromChainId = _fromChainId;
        fromLineAddress = _fromLineAddress;
        fromDappAddress = _fromDappAddress;
        message = _message;
        lineInfo = IMessageLine(_fromLineAddress).getLineInfo();
    }
}
