// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISafeMsgportModule {
    function setup(address xAccount, uint256 chainId, address owner, address port_) external;
}
