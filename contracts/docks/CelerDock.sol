// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./base/BaseMessageDock.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";
import "../utils/Utils.sol";

contract CelerDock is BaseMessageDock, MessageSenderApp, MessageReceiverApp {
    address public remoteDockAddress;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        address _messageBus
    ) BaseMessageDock(_localMsgportAddress, _chainIdConverter) {
        messageBus = _messageBus;
    }

    function setChainIdConverter(address _chainIdConverter) external onlyOwner {
        setChainIdConverterInternal(_chainIdConverter);
    }

    function newOutboundLane(
        uint64 _toChainId,
        address _toDockAddress
    ) external override onlyOwner {
        addOutboundLaneInternal(_toChainId, _toDockAddress);
    }

    function newInboundLane(
        uint64 _fromChainId,
        address _fromDockAddress
    ) external override onlyOwner {
        addInboundLaneInternal(_fromChainId, _fromDockAddress);
    }

    function chainIdUp(uint64 _chainId) public view returns (uint64) {
        return chainIdMapping.up(Utils.uint64ToBytes(_chainId));
    }

    function chainIdDown(uint64 _chainId) public view returns (uint64) {
        return Utils.bytesToUint64(chainIdMapping.down(_chainId));
    }

    //////////////////////////////////////////
    // For sending
    //////////////////////////////////////////
    // override BaseMessageDock
    function callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory /*_params*/
    ) internal override {
        bytes memory celerMessage = abi.encode(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        // https://github.com/celer-network/sgn-v2-contracts/blob/1c65d5538ff8509c7e2626bb1a857683db775231/contracts/message/interfaces/IMessageBus.sol#LL122C17-L122C17
        uint256 fee = IMessageBus(messageBus).calcFee(celerMessage);

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= fee, "!fee");

        // refund fee
        if (paid > fee) {
            payable(msg.sender).transfer(paid - fee);
        }

        sendMessage(
            _outboundLane.toDockAddress,
            chainIdDown(_outboundLane.toChainId),
            celerMessage,
            msg.value
        );
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
        (
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode((_celerMessage), (address, address, bytes));

        InboundLane memory inboundLane = inboundLanes[chainIdUp(_srcChainId)];
        require(
            inboundLane.fromDockAddress == _srcContract,
            "invalid source dock address"
        );

        recv(fromDappAddress, inboundLane, toDappAddress, messagePayload);

        return ExecutionStatus.Success;
    }

    // override BaseMessageDock
    function approveToRecv(
        address /*_fromDappAddress*/,
        InboundLane memory /*_inboundLane*/,
        address /*_toDappAddress*/,
        bytes memory /*_messagePayload*/
    ) internal view override returns (bool) {
        require(
            msg.sender == address(this),
            "only self contract can call recv"
        );
        return true;
    }
}
