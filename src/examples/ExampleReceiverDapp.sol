// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../user/Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(uint256 fromChainId, address fromDapp, address localPort, bytes message);

    // local port address
    address public immutable PORT;
    // remote dapp address
    address public immutable DAPP;

    constructor(address port, address dapp) {
        PORT = port;
        DAPP = dapp;
    }

    /// @notice You could check the fromDapp address or messagePort address.
    function xxx(bytes calldata message) external {
        uint256 fromChainId = _fromChainId();
        address fromDapp = _xmsgSender();
        address localPort = _msgPort();
        require(localPort == PORT);
        require(fromDapp == DAPP);
        emit DappMessageRecv(fromChainId, fromDapp, localPort, message);
    }
}
