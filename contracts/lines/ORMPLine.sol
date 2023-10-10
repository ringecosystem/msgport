// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";

interface IORMP {
    function send(uint256 toChainId, address to, bytes calldata encoded, bytes calldata params)
        external
        payable
        returns (bytes32);
}

contract ORMPLine is BaseMessageLine {
    address public immutable ORMP;

    constructor(address ormp, Metadata memory metadata) BaseMessageLine(metadata) {
        ORMP = ormp;
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes memory message, bytes memory params)
        internal
        override
    {
        bytes memory encoded =
            abi.encodeWithSelector(ORMPLine.recv.selector, LOCAL_CHAINID(), fromDapp, toDapp, message);
        IORMP(ORMP).send{value: msg.value}(toChainId, ORMP, encoded, params);
    }

    function recv(uint256 fromChainId, address fromDapp, address toDapp, bytes memory message) external {
        require(msg.sender == ORMP, "!auth");
        _recv(fromChainId, fromDapp, toDapp, message);
    }
}
