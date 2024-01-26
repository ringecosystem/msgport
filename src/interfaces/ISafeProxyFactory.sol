// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISafeProxyFactory {
    function proxyCreationCode() external pure returns (bytes memory);
}
