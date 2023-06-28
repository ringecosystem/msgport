// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMessageDock {
    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) external payable;
}
