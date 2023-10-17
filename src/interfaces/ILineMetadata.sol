// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILineMetadata {
    function name() external view returns (string memory);
    function uri() external view returns (string memory);
}
