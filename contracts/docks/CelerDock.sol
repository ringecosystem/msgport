// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/BaseMessageDock.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";
import "../utils/Utils.sol";

contract CelerDock is BaseMessageDock, MessageSenderApp, MessageReceiverApp {
    address public remoteDockAddress;
    mapping(uint64 => uint64) public nonces;

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

    function chainIdUp(uint64 _chainId) public view returns (uint64) {
        return chainIdMapping.up(Utils.uint64ToBytes(_chainId));
    }

    function chainIdDown(uint64 _chainId) public view returns (uint64) {
        return Utils.bytesToUint64(chainIdMapping.down(_chainId));
    }

    function addRemoteDock(
        uint64 _remoteChainId,
        address _remoteDockAddress
    ) external onlyOwner {
        addRemoteDockInternal(_remoteChainId, _remoteDockAddress);
    }

    //////////////////////////////////////////
    // For sending
    //////////////////////////////////////////
    // override BaseMessageDock
    function callRemoteRecv(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDockAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
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
            _toDockAddress,
            chainIdDown(_toChainId),
            celerMessage,
            msg.value
        );

        return nonces[_toChainId]++;
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
        recv(
            chainIdUp(_srcChainId),
            _srcContract,
            fromDappAddress,
            toDappAddress,
            messagePayload
        );
        return ExecutionStatus.Success;
    }

    // override BaseMessageDock
    function approveToRecv(
        uint64 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal view override returns (bool) {
        require(
            msg.sender == address(this),
            "only self contract can call recv"
        );
        return true;
    }
}
