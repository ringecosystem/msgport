// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(
        bytes32 messageId,
        uint256 fromChainId,
        address fromDappAddress,
        address localLineAddress,
        bytes message
    );

    constructor(address msgPort) Application(msgPort) {}

    function xxx(bytes calldata message) external {
        uint256 fromChainId = _fromChainId();
        bytes32 messageId = _messageId();
        address fromDappAddress = _xmsgSender();
        address localLineAddress = _lineAddress();
        emit DappMessageRecv(messageId, fromChainId, fromDappAddress, localLineAddress, message);
    }
}
