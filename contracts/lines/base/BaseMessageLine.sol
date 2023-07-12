// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessageLine.sol";
import "../../interfaces/IMessagePort.sol";
import "../../interfaces/IChainIdMapping.sol";

abstract contract BaseMessageLine is IMessageLine{
    struct OutboundLane {
        uint64 toChainId;
        address toLineAddress;
    }

    struct InboundLane {
        uint64 fromChainId;
        address fromLineAddress;
    }

    // toChainId => OutboundLane
    mapping(uint64 => OutboundLane) public outboundLanes;
    // fromChainId => InboundLane
    mapping(uint64 => InboundLane) public inboundLanes;

    address public localMessagingContractAddress;
    IMessagePort public immutable LOCAL_MSGPORT;

    constructor(
        address _localMsgportAddress,
        address _localMessagingContractAddress
    ) {
        LOCAL_MSGPORT = IMessagePort(_localMsgportAddress);
        localMessagingContractAddress = _localMessagingContractAddress;
    }

    function getLocalChainId() public view returns (uint64) {
        return LOCAL_MSGPORT.getLocalChainId();
    }

    function outboundLaneExists(
        uint64 _toChainId
    ) public view virtual returns (bool) {
        return outboundLanes[_toChainId].toLineAddress != address(0);
    }

    function _addOutboundLaneInternal(
        uint64 _toChainId,
        address _toLineAddress
    ) internal virtual {
        require(
            outboundLaneExists(_toChainId) == false,
            "Line: OutboundLane already exists"
        );
        outboundLanes[_toChainId] = OutboundLane({
            toChainId: _toChainId,
            toLineAddress: _toLineAddress
        });
    }

    function inboundLaneExists(
        uint64 _fromChainId
    ) public view virtual returns (bool) {
        return inboundLanes[_fromChainId].fromLineAddress != address(0);
    }

    function _addInboundLaneInternal(
        uint64 _fromChainId,
        address _fromLineAddress
    ) internal virtual {
        require(
            inboundLaneExists(_fromChainId) == false,
            "Line: InboundLane already exists"
        );
        inboundLanes[_fromChainId] = InboundLane({
            fromChainId: _fromChainId,
            fromLineAddress: _fromLineAddress
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
    ) public payable virtual {
        // check this is called by local msgport
        _requireCalledByMsgport();

        _callRemoteRecv(
            _fromDappAddress,
            outboundLanes[_toChainId],
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
    ) public virtual {
        require(
            msg.sender == localMessagingContractAddress,
            "Line: Only can be called by local messaging contract"
        );

        // call local msgport to receive message
        LOCAL_MSGPORT.recv(
            _inboundLane.fromChainId,
            _fromDappAddress,
            _toDappAddress,
            _message
        );
    }

    function _requireCalledByMsgport() internal view virtual {
        // check this is called by local msgport
        require(
            msg.sender == address(LOCAL_MSGPORT),
            "Line: Only can be called by local msgport"
        );
    }
}
