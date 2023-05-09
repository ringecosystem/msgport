// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./IMsgport.sol";

// dock knows hot to send message to remote dock.
abstract contract MessageDockBase {
    IMsgport public immutable localMsgport;

    constructor(address _localMsgportAddress) {
        localMsgport = IMsgport(_localMsgportAddress);
    }

    ////////////////////////////////////////
    // Abstract functions
    ////////////////////////////////////////
    // For receiving
    function allowToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal virtual returns (bool);

    // For sending
    function callRemoteDockRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal virtual returns (uint256);

    function getRemoteDockAddress() public virtual returns (address);

    function getRelayFee(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view virtual returns (uint256);

    function getDeliveryGas(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view virtual returns (uint256);

    ////////////////////////////////////////
    // Public functions
    ////////////////////////////////////////
    // called by local msgport
    function send(
        address _fromDappAddress,
        address _toDappAddress,
        bytes calldata _messagePayload
    ) public payable returns (uint256) {
        // check this is called by local msgport
        require(
            msg.sender == address(localMsgport),
            "not allowed to be called by others except local msgport"
        );
        address remoteDockAddress = getRemoteDockAddress();
        require(remoteDockAddress != address(0), "remote dock not set");

        return
            callRemoteDockRecv(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload
            );
    }

    // called by remote dock through low level messaging contract or self
    function recv(
        address _srcDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) public {
        require(
            allowToRecv(_fromDappAddress, _toDappAddress, _messagePayload),
            "!permitted"
        );

        // only allow messages from remote dock
        require(_srcDockAddress == getRemoteDockAddress(), "!remoteDock");

        // call local msgport to receive message
        localMsgport.recv(_fromDappAddress, _toDappAddress, _messagePayload);
    }
}
