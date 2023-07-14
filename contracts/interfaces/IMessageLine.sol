// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageLine {
    function getLineInfo() external view returns (string memory);

    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) external payable;
}
