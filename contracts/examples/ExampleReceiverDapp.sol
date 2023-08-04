// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../interfaces/IMessageReceiver.sol";

contract ExampleReceiverDapp is IMessageReceiver {
    event DappMessageRecv(
        uint256 fromChainId,
        address fromDappAddress,
        address localLineAddress,
        bytes message
    );

    function recv(
        uint256 _fromChainId,
        address _fromDappAddress,
        address _localLineAddress,
        bytes calldata _message
    ) external {
        emit DappMessageRecv(_fromChainId, _fromDappAddress, _localLineAddress, _message);
    }
}
