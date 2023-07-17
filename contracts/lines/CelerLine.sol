// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./base/BaseMessageLine.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";
import "../utils/Utils.sol";

contract CelerLine is BaseMessageLine, MessageSenderApp, MessageReceiverApp {
    address public remoteLineAddress;

    IChainIdMapping public chainIdMapping;

    constructor(
        address _localMsgportAddress,
        address _chainIdMapping,
        address _messageBus
    ) BaseMessageLine(_localMsgportAddress, _messageBus) {
        chainIdMapping = IChainIdMapping(_chainIdMapping);
    }

    function setChainIdMapping(address _chainIdConverter) external onlyOwner {
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    function addToLine(
        uint64 _toChainId,
        address _toLineAddress
    ) external onlyOwner {
        _addToLine(_toChainId, _toLineAddress);
    }

    function addFromLine(
        uint64 _fromChainId,
        address _fromLineAddress
    ) external onlyOwner {
        _addFromLine(_fromChainId, _fromLineAddress);
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
    // override BaseMessageLine
    function _callRemoteRecv(
        address _fromDappAddress,
        uint64 _toChainId,
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
            toLineAddressLookup[_toChainId],
            chainIdDown(_toChainId),
            celerMessage,
            fee
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
        uint64 fromChainId = chainIdUp(_srcChainId);
        require(
            fromLineAddressLookup[fromChainId] == _srcContract,
            "invalid source line address"
        );

        recv(fromChainId, fromDappAddress, toDappAddress, messagePayload);

        return ExecutionStatus.Success;
    }
}
