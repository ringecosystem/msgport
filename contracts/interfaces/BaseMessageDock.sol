// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IMessagePort.sol";
import "./IChainIdMapping.sol";

abstract contract BaseMessageDock {
    struct OutboundLane {
        uint64 toChainId;
        address toDockAddress;
        uint256 nonce;
    }

    struct InboundLane {
        uint64 fromChainId;
        address fromDockAddress;
    }

    IMessagePort public immutable localMsgport;
    IChainIdMapping public chainIdMapping;

    // tgtChainId => OutboundLane
    mapping(uint64 => OutboundLane) public outboundLanes;
    // srcChainId => srcDockAddress => InboundLane
    mapping(uint64 => InboundLane) public inboundLanes;

    constructor(address _localMsgportAddress, address _chainIdConverter) {
        localMsgport = IMessagePort(_localMsgportAddress);
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    function getLocalChainId() public view returns (uint64) {
        return localMsgport.getLocalChainId();
    }

    function outboundLaneExists(uint64 _toChainId) public view returns (bool) {
        return outboundLanes[_toChainId].toDockAddress != address(0);
    }

    function addOutboundLaneInternal(
        uint64 _toChainId,
        address _toDockAddress
    ) internal {
        require(
            outboundLaneExists(_toChainId) == false,
            "outboundLane already exists"
        );
        outboundLanes[_toChainId] = OutboundLane({
            toChainId: _toChainId,
            toDockAddress: _toDockAddress,
            nonce: 0
        });
    }

    function getOutboundLaneNonce(
        uint64 _toChainId
    ) public view returns (uint256) {
        return outboundLanes[_toChainId].nonce;
    }

    function inboundLaneExists(uint64 _fromChainId) public view returns (bool) {
        return inboundLanes[_fromChainId].fromDockAddress != address(0);
    }

    function addInboundLaneInternal(
        uint64 _fromChainId,
        address _fromDockAddress
    ) internal {
        require(
            inboundLaneExists(_fromChainId) == false,
            "inboundLane already exists"
        );
        inboundLanes[_fromChainId] = InboundLane({
            fromChainId: _fromChainId,
            fromDockAddress: _fromDockAddress
        });
    }

    function setChainIdConverterInternal(address _chainIdConverter) public {
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    ////////////////////////////////////////
    // Abstract functions
    ////////////////////////////////////////
    // For receiving
    function approveToRecv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    function newInboundLane(
        uint64 _fromChainId,
        address _fromDockAddress
    ) external virtual;

    // For sending
    function callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual;

    function newOutboundLane(
        uint64 _toChainId,
        address _toDockAddress
    ) external virtual;

    ////////////////////////////////////////
    // Public functions
    ////////////////////////////////////////
    // called by local msgport
    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) public payable {
        // check this is called by local msgport
        require(
            msg.sender == address(localMsgport),
            "not allowed to be called by others except local msgport"
        );

        OutboundLane memory outboundLane = outboundLanes[_toChainId];
        bytes memory message = abi.encode(outboundLane.nonce, _payload);
        outboundLane.nonce += 1;
        outboundLanes[_toChainId] = outboundLane;

        callRemoteRecv(
            _fromDappAddress,
            outboundLanes[_toChainId],
            _toDappAddress,
            message,
            _params
        );
    }

    // called by remote dock through low level messaging contract or self
    function recv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _message
    ) public {
        (uint256 nonce, bytes memory payload) = abi.decode(
            _message,
            (uint256, bytes)
        );
        require(
            approveToRecv(
                _fromDappAddress,
                _inboundLane,
                _toDappAddress,
                payload
            ),
            "!permitted"
        );

        // call local msgport to receive message
        localMsgport.recv(
            _inboundLane.fromChainId,
            _fromDappAddress,
            _toDappAddress,
            payload,
            nonce
        );
    }
}
