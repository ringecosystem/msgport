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

    function _callRemoteRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual;

    function _approveToRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) public payable virtual override {
        // check this is called by local msgport
        super.send(
            _fromDappAddress,
            _toChainId,
            _toDappAddress,
            _payload,
            _params
        );

        _callRemoteRecvForSingle(
            _fromDappAddress,
            _toDappAddress,
            _payload,
            _params
        );
    }

    function recv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _message
    ) public virtual override {
        require(
            _approveToRecvForSingle(
                _fromDappAddress,
                _toDappAddress,
                _message
            ),
            "!permitted"
        );

        super.recv(
            _fromDappAddress,
            _inboundLane,
            _toDappAddress,
            _message
        );
    }
}
