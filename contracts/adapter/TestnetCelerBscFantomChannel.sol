// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/AbstractMessageChannel.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";

import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";

contract TestnetCelerBscFantomChannel is
    AbstractMessageChannel,
    MessageSenderApp,
    MessageReceiverApp
{
    uint64 public constant BSC_CHAIN_ID = 97;
    uint64 public constant FANTOM_CHAIN_ID = 4002;
    address public remoteChannelAddress;

    constructor(
        address _msgportAddress,
        address _messageBus
    ) AbstractMessageChannel(_msgportAddress) {
        messageBus = _messageBus;
    }

    function setRemoteChannelAddress(
        address _remoteChannelAddress
    ) external onlyOwner {
        remoteChannelAddress = _remoteChannelAddress;
    }

    //////////////////////////////////////////
    // For sending
    //////////////////////////////////////////
    // override AbstractMessageChannel
    function getRemoteChannelAddress() public view override returns (address) {
        return remoteChannelAddress;
    }

    // override AbstractMessageChannel
    function getRelayFee(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view override returns (uint256) {
        return
            IMessageBus(messageBus).calcFee(
                abi.encode(_fromDappAddress, _toDappAddress, _messagePayload)
            );
    }

    // override AbstractMessageChannel
    function getDeliveryGas(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view override returns (uint256) {
        return 0;
    }

    // override AbstractMessageChannel
    function callRemoteChannelRecv(
        address _remoteChannelAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal override returns (uint256) {
        bytes memory celerMessage = abi.encode(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );
        sendMessage(
            _remoteChannelAddress,
            FANTOM_CHAIN_ID,
            celerMessage,
            msg.value
        );
        return 0;
    }

    //////////////////////////////////////////
    // For receiving
    //////////////////////////////////////////
    // override MessageApp
    // called by MessageBus on destination chain to receive cross-chain messages
    function executeMessage(
        address _srcContract,
        uint64 _srcChainId,
        bytes calldata _celerMessage,
        address // executor
    ) external payable override onlyMessageBus returns (ExecutionStatus) {
        require(_srcChainId == BSC_CHAIN_ID, "Invalid chainId");
        (
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode((_celerMessage), (address, address, bytes));
        recv(fromDappAddress, toDappAddress, messagePayload);
        return ExecutionStatus.Success;
    }

    // override AbstractMessageChannel
    function permitted(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal view override returns (bool) {
        return true;
    }
}
