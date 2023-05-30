// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./IMsgport.sol";
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
    ) internal virtual returns (uint256);

    function approveToRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    function callRemoteRecv(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDockAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        return
            callRemoteRecvForSingle(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                _params
            );
    }

    function approveToRecv(
        uint64 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
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
