// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./BaseMessageDock.sol";

// dock knows hot to send message to remote dock.
abstract contract SingleTargetMessageDock is BaseMessageDock {
    uint64 public remoteChainId;
    address public remoteDockAddress;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        uint64 _remoteChainId,
        address _remoteDockAddress
    ) BaseMessageDock(_localMsgportAddress, _chainIdConverter) {
        remoteChainId = _remoteChainId;
        remoteDockAddress = _remoteDockAddress;
    }

    function callRemoteRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual;

    function approveToRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    function callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory /*_outboundLane*/,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        callRemoteRecvForSingle(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload,
            _params
        );
    }

    function approveToRecv(
        address _fromDappAddress,
        InboundLane memory /*_inboundLane*/,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal override returns (bool) {
        return
            approveToRecvForSingle(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload
            );
    }
}
