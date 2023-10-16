// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(uint256 fromChainId, address fromDapp, address localLine, bytes message);

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
        address fromDapp = _xmsgSender();
        address localLine = _msgSender();
        require(localLine == LINE);
        require(fromDapp == DAPP);
        emit DappMessageRecv(fromChainId, fromDapp, localLine, message);
    }
}
