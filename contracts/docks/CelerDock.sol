// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/MessageDockBase.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";

import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";

contract CelerDock is MessageDockBase, MessageSenderApp, MessageReceiverApp {
    uint64 public immutable SRC_CHAIN_ID;
    uint64 public immutable TGT_CHAIN_ID;
    address public remoteDockAddress;
    uint64 public nextNonce = 0;

    constructor(
        address _msgportAddress,
        address _messageBus,
        uint64 _srcChainId,
        uint64 _tgtChainId
    ) MessageDockBase(_msgportAddress) {
        messageBus = _messageBus;
        SRC_CHAIN_ID = _srcChainId;
        TGT_CHAIN_ID = _tgtChainId;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) external onlyOwner {
        remoteDockAddress = _remoteDockAddress;
    }

    //////////////////////////////////////////
    // For sending
    //////////////////////////////////////////
    // override MessageDockBase
    function getRemoteDockAddress() public view override returns (address) {
        return remoteDockAddress;
    }

    // override MessageDockBase
    function callRemoteDockRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal override returns (uint256) {
        bytes memory celerMessage = abi.encode(
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );
        sendMessage(remoteDockAddress, TGT_CHAIN_ID, celerMessage, msg.value);

        return nextNonce++;
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
        require(_srcChainId == SRC_CHAIN_ID, "Invalid chainId");
        (
            address srcDockAddress,
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode((_celerMessage), (address, address, address, bytes));
        recv(srcDockAddress, fromDappAddress, toDappAddress, messagePayload);
        return ExecutionStatus.Success;
    }

    // override MessageDockBase
    function allowToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal view override returns (bool) {
        require(
            msg.sender == address(this),
            "only self contract can call recv"
        );
        return true;
    }
}
