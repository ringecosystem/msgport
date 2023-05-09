// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../../interfaces/IMessageReceiver.sol";

contract FantomDapp is IMessageReceiver {
    address public fromDappAddress;
    bytes public message;

    function recv(address _fromDappAddress, bytes calldata _message) external {
        fromDappAddress = _fromDappAddress;
        message = _message;
    }
}
