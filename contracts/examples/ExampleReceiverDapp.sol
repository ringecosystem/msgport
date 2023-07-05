// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../interfaces/IMessageReceiver.sol";
import "../interfaces/IMessageDock.sol";

contract ExampleReceiverDapp is IMessageReceiver {
    uint256 public fromChainId;
    address public fromDockAddress;
    address public fromDappAddress;
    bytes public message;
    string public providerName;

    function recv(
        uint256 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
        bytes calldata _message
    ) external {
        fromChainId = _fromChainId;
        fromDockAddress = _fromDockAddress;
        fromDappAddress = _fromDappAddress;
        message = _message;

        providerName = IMessageDock(_fromDockAddress).getProviderName();
    }
}
