// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPortRegistry {
    function get(uint256 chainId, address port) external view returns (string memory);
    function get(uint256 chainId, string calldata name) external view returns (address);
}
