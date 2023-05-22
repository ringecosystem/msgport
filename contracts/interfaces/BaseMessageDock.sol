// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./IMsgport.sol";
import "./IChainIdMapping.sol";

// dock knows hot to send message to remote dock.
abstract contract BaseMessageDock {
    IMsgport public immutable localMsgport;
    IChainIdMapping public chainIdMapping;

    // remoteChainId => remoteDockAddress
    mapping(uint256 => address) public remoteDockAddresses;

    constructor(address _localMsgportAddress, address _chainIdConverter) {
        localMsgport = IMsgport(_localMsgportAddress);
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    function getLocalChainId() public view returns (uint256) {
        return localMsgport.getLocalChainId();
    }

    function remoteDockExists(
        uint256 _remoteChainId,
        address _remoteDockAddress
    ) public view returns (bool) {
        return remoteDockAddresses[_remoteChainId] == _remoteDockAddress;
    }

    function setChainIdConverterInternal(address _chainIdConverter) internal {
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    function addRemoteDockInternal(
        uint256 _remoteChainId,
        address _remoteDockAddress
    ) internal {
        require(
            remoteDockAddresses[_remoteChainId] == address(0),
            "remote dock already exists"
        );
        remoteDockAddresses[_remoteChainId] = _remoteDockAddress;
    }

    ////////////////////////////////////////
    // Abstract functions
    ////////////////////////////////////////
    // For receiving
    function approveToRecv(
        uint256 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual returns (bool);

    // For sending
    function callRemoteRecv(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDockAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual returns (uint256);

    ////////////////////////////////////////
    // Public functions
    ////////////////////////////////////////
    // called by local msgport
    function send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) public payable returns (uint256) {
        // check this is called by local msgport
        require(
            msg.sender == address(localMsgport),
            "not allowed to be called by others except local msgport"
        );

        return
            callRemoteRecv(
                _fromDappAddress,
                _toChainId,
                remoteDockAddresses[_toChainId],
                _toDappAddress,
                _messagePayload,
                _params
            );
    }

    // called by remote dock through low level messaging contract or self
    function recv(
        uint256 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) public {
        require(
            approveToRecv(
                _fromChainId,
                _fromDockAddress,
                _fromDappAddress,
                _toDappAddress,
                _messagePayload
            ),
            "!permitted"
        );

        // call local msgport to receive message
        localMsgport.recv(
            _fromChainId,
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );
    }
}
