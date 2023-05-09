// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./IMsgport.sol";

// channel knows hot to send message to remote channel.
abstract contract AbstractMessageChannel {
    IMsgport public immutable localMsgport;

    constructor(address _localMsgportAddress) {
        localMsgport = IMsgport(_localMsgportAddress);
    }

    ////////////////////////////////////////
    // Abstract functions
    ////////////////////////////////////////
    // For receiving
    function permitted(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal virtual returns (bool);

    // For sending
    function callRemoteChannelRecv(
        address _remoteChannelAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal virtual returns (uint256);

    function getRemoteChannelAddress() public virtual returns (address);

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
        address remoteChannelAddress = getRemoteChannelAddress();
        require(remoteChannelAddress != address(0), "remote channel not set");

        return
            callRemoteChannelRecv(
                remoteChannelAddress,
                _fromDappAddress,
                _toDappAddress,
                _messagePayload
            );
    }

    // called by remote channel through low level messaging contract or self
    function recv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) public {
        require(
            permitted(_fromDappAddress, _toDappAddress, _messagePayload),
            "!permitted"
        );

        // call local msgport to receive message
        localMsgport.recv(_fromDappAddress, _toDappAddress, _messagePayload);
    }
}
