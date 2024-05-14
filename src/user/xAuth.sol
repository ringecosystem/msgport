// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Application.sol";
import "../interfaces/IPortRegistry.sol";

abstract contract xAuth is Application {
    function xOwner() public virtual returns (uint256, address);
    function checkPort(address port) public virtual returns (bool);

    function _checkXAuth() internal virtual {
        address port = _msgPort();
        uint256 fromChainId = _fromChainId();
        (uint256 chainId, address owner) = xOwner();
        require(fromChainId != block.chainid, "!fromChainId");
        require(checkPort(port), "!trusted");
        require(fromChainId == chainId, "!xOwner.chainId");
        require(_xmsgSender() == owner, "!xOwner.owner");
    }
}
