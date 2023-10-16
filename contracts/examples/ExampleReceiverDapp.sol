// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Application.sol";

contract ExampleReceiverDapp is Application {
    event DappMessageRecv(
        uint256 fromChainId, address fromDappAddress, address localLineAddress, bytes message
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
        address fromDappAddress = _xmsgSender();
        address localLineAddress = _msgSender();
        require(localLineAddress == LINE);
        require(fromDappAddress == DAPP);
        emit DappMessageRecv(fromChainId, fromDappAddress, localLineAddress, message);
    }
}
