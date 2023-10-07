// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(
        bytes32 messageId, uint256 fromChainId, address fromDappAddress, address localLineAddress, bytes message
    );

    address public msgLine;

    constructor(address msgPort, address line) Application(msgPort) {
        msgLine = line;
    }

    function xxx(bytes calldata message) external {
        uint256 fromChainId = _fromChainId();
        bytes32 messageId = _messageId();
        address fromDappAddress = _xmsgSender();
        address localLineAddress = _lineAddress();
        require(localLineAddress == msgLine);
        emit DappMessageRecv(messageId, fromChainId, fromDappAddress, localLineAddress, message);
    }
}
