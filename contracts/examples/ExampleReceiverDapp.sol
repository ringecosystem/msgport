// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(
        bytes32 messageId, uint256 fromChainId, address fromDappAddress, address localLineAddress, bytes message
    );

    mapping(address => bool) trustedLines;

    constructor(address[] memory _trustedLines) Application() {
        for (uint256 i = 0; i < _trustedLines.length; i++) {
            trustedLines[_trustedLines[i]] = true;
        }
    }

    function xxx(bytes calldata message) external {
        uint256 fromChainId = _fromChainId();
        bytes32 messageId = _messageId();
        address fromDappAddress = _xmsgSender();
        address localLineAddress = _lineAddress();
        require(trustedLines[localLineAddress], "Untrusted line address");
        emit DappMessageRecv(messageId, fromChainId, fromDappAddress, localLineAddress, message);
    }
}
