// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageLine {
    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) external payable;

    function estimateFee(
        uint64 _toChainId, // Dest msgport chainId
        bytes calldata _payload,
        bytes calldata _params
    ) external view returns (uint256);
}
