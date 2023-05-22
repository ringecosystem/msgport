// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./IMsgport.sol";
import "./BaseMessageDock.sol";

// dock knows hot to send message to remote dock.
abstract contract SingleTargetMessageDock is BaseMessageDock {
    uint256 public remoteChainId;
    address public remoteDockAddress;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        uint256 _remoteChainId,
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
        uint256 _toChainId,
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
        uint256 _fromChainId,
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
