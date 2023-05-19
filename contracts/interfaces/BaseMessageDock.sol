// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./IMsgport.sol";

// dock knows hot to send message to remote dock.
abstract contract BaseMessageDock {
    IMsgport public immutable localMsgport;
    uint public immutable localChainId;
    uint public immutable remoteChainId;

    constructor(address _localMsgportAddress, uint _remoteChainId) {
        localMsgport = IMsgport(_localMsgportAddress);
        localChainId = localMsgport.getLocalChainId();

        require(
            localChainId != _remoteChainId,
            "!remoteChainId == localChainId"
        );
        remoteChainId = _remoteChainId;
    }

    ////////////////////////////////////////
    // Abstract functions
    ////////////////////////////////////////
    // For receiving
    function approveToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    // For sending
    function callRemoteRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual returns (uint256);

    function setRemoteDockAddress(address _remoteDockAddress) public virtual;

    function getRemoteDockAddress() public virtual returns (address);

    ////////////////////////////////////////
    // Public functions
    ////////////////////////////////////////
    // called by local msgport
    function send(
        address _fromDappAddress,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes memory _params
    ) public payable returns (uint256) {
        // check this is called by local msgport
        require(
            msg.sender == address(localMsgport),
            "not allowed to be called by others except local msgport"
        );
        address remoteDockAddress = getRemoteDockAddress();
        require(remoteDockAddress != address(0), "remote dock not set");

        return
            callRemoteRecv(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                _params
            );
    }

    // called by remote dock through low level messaging contract or self
    function recv(
        address _toDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) public {
        require(
            approveToRecv(_fromDappAddress, _toDappAddress, _messagePayload),
            "!permitted"
        );

        // only allow messages from remote dock
        require(_toDockAddress == getRemoteDockAddress(), "!remoteDock");

        // call local msgport to receive message
        localMsgport.recv(
            remoteChainId,
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );
    }
}
