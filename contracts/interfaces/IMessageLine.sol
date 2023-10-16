// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageLine {
    error MessageFailure(bytes errorData);

    function send(uint256 toChainId, address toDapp, bytes memory payload, bytes memory params) external payable;

    function estimateFee(
        uint256 toChainId, // Dest lineRegistry chainId
        bytes calldata payload,
        bytes calldata params
    ) external view returns (uint256);
}
