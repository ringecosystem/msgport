// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageDock {
    function getProviderName() external view returns (string memory);

    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) external payable;
}
