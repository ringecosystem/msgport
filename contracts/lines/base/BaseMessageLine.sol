// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessageLine.sol";
import "../../interfaces/IMessagePort.sol";

abstract contract BaseMessageLine is IMessageLine {
    struct Metadata {
        string name;
        string provider;
        string description;
        FeeEstimation feeEstimation;
    }

    struct FeeEstimation {
        address feeContract;
        string feeMethod;
        string offChainFeeApi;
    }

    // toChainId => toLineAddress
    mapping(uint64 => address) public toLineAddressLookup;
    // fromChainId => fromLineAddress
    mapping(uint64 => address) public fromLineAddressLookup;

    address public immutable localMessagingContractAddress;
    IMessagePort public immutable LOCAL_MSGPORT;

    Metadata public metadata;

    constructor(
        address _localMsgportAddress,
        address _localMessagingContractAddress,
        Metadata memory _metadata
    ) {
        metadata = _metadata;
        LOCAL_MSGPORT = IMessagePort(_localMsgportAddress);
        localMessagingContractAddress = _localMessagingContractAddress;
    }

    function _updateFeeEstimation(
        FeeEstimation memory _feeEstimation
    ) internal virtual {
        metadata.feeEstimation = _feeEstimation;
    }

    function getLocalChainId() public view returns (uint64) {
        return LOCAL_MSGPORT.getLocalChainId();
    }

    function toLineExists(
        uint64 _toChainId
    ) public view virtual returns (bool) {
        return toLineAddressLookup[_toChainId] != address(0);
    }

    function _addToLine(
        uint64 _toChainId,
        address _toLineAddress
    ) internal virtual {
        require(
            toLineExists(_toChainId) == false,
            "Line: ToLine already exists"
        );
        toLineAddressLookup[_toChainId] = _toLineAddress;
    }

    function fromLineExists(
        uint64 _fromChainId
    ) public view virtual returns (bool) {
        return fromLineAddressLookup[_fromChainId] != address(0);
    }

    function _addFromLine(
        uint64 _fromChainId,
        address _fromLineAddress
    ) internal virtual {
        require(
            fromLineExists(_fromChainId) == false,
            "Line: FromLine already exists"
        );
        fromLineAddressLookup[_fromChainId] = _fromLineAddress;
    }

    function _send(
        address _fromDappAddress,
        uint64 _toChainId,
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

        _send(
            _fromDappAddress,
            _toChainId,
            _toDappAddress,
            _payload,
            _params
        );
    }

    function _recv(
        uint64 _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _message
    ) internal {
        // call local msgport to receive message
        LOCAL_MSGPORT.recv(
            _fromChainId,
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
