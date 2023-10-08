// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(
        bytes32 messageId, uint256 fromChainId, address fromDappAddress, address localLineAddress, bytes message
    );

    // local line address
    address public immutable LINE;
    // remote dapp address
    address public immutable DAPP;

    constructor(address line, address dapp) {
        LINE = line;
        DAPP = dapp;
    }

    function xxx(bytes calldata message) external {
        uint256 fromChainId = _fromChainId();
        bytes32 messageId = _messageId();
        address fromDappAddress = _xmsgSender();
        address localLineAddress = _msgSender();
        require(localLineAddress == LINE);
        require(fromDappAddress == DAPP);
        emit DappMessageRecv(messageId, fromChainId, fromDappAddress, localLineAddress, message);
    }
}
