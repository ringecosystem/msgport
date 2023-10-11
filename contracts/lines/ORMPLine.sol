// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "ORMP/interfaces/IEndpoint.sol";
import "ORMP/user/Application.sol";

contract ORMPLine is BaseMessageLine, Application {
    constructor(address ormp, Metadata memory metadata) BaseMessageLine(metadata) Application(ormp) {}

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes memory message, bytes memory params)
        internal
        override
    {
        bytes memory encoded = abi.encodeWithSelector(ORMPLine.recv.selector, fromDapp, toDapp, message);
        IEndpoint(TRUSTED_ORMP).send{value: msg.value}(toChainId, address(this), encoded, params);
    }

    function recv(address fromDapp, address toDapp, bytes memory message) external {
        require(_xmsgSender() == address(this), "!auth");
        _recv(_fromChainId(), fromDapp, toDapp, message);
    }
}
