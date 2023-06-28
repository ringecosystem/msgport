// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessagePort.sol";
import "../../interfaces/IChainIdMapping.sol";
import "./BaseMessageDock.sol";

abstract contract MultiTargetMessageDock is BaseMessageDock {
    // tgtChainId => OutboundLane
    mapping(uint64 => OutboundLane) public outboundLanes;
    // srcChainId => srcDockAddress => InboundLane
    mapping(uint64 => InboundLane) public inboundLanes;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter
    ) BaseMessageDock(_localMsgportAddress, _chainIdConverter) {}

    // For receiving
    function newInboundLane(
        uint64 _fromChainId,
        address _fromDockAddress
    ) external virtual;

    // For sending
    function newOutboundLane(
        uint64 _toChainId,
        address _toDockAddress
    ) external virtual;

    function outboundLaneExists(uint64 _toChainId) public view virtual returns (bool) {
        return outboundLanes[_toChainId].toDockAddress != address(0);
    }

    function _addOutboundLaneInternal(
        uint64 _toChainId,
        address _toDockAddress
    ) internal virtual {
        require(
            outboundLaneExists(_toChainId) == false,
            "outboundLane already exists"
        );
        outboundLanes[_toChainId] = OutboundLane({
            toChainId: _toChainId,
            toDockAddress: _toDockAddress
        });
    }

    function inboundLaneExists(uint64 _fromChainId) public view virtual returns (bool) {
        return inboundLanes[_fromChainId].fromDockAddress != address(0);
    }

    function _addInboundLaneInternal(
        uint64 _fromChainId,
        address _fromDockAddress
    ) internal virtual {
        require(
            inboundLaneExists(_fromChainId) == false,
            "inboundLane already exists"
        );
        inboundLanes[_fromChainId] = InboundLane({
            fromChainId: _fromChainId,
            fromDockAddress: _fromDockAddress
        });
    }

    function _callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual;

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

        _callRemoteRecv(
            _fromDappAddress,
            outboundLanes[_toChainId],
            _toDappAddress,
            _payload,
            _params
        );
    }

    function _approveToRecv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    function recv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _message
    ) public virtual override {
        require(
            _approveToRecv(
                _fromDappAddress,
                _inboundLane,
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
