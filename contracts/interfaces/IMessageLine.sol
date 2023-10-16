// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageLine {
    error MessageFailure(bytes errorData);

    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params) external payable;

    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        returns (uint256);
}
