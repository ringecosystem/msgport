// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "../chain-id-mappings/CelerChainIdMapping.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";
import "../utils/Utils.sol";

contract CelerLine is BaseMessageLine, LineLookup, CelerChainIdMapping, MessageSenderApp, MessageReceiverApp {
    address public remoteLineAddress;
    address public immutable lowLevelMessager;

    constructor(
        address _messageBus,
        string memory _name,
        uint256[] memory _lineRegistryChainIds,
        uint64[] memory _celerChainIds
    ) BaseMessageLine(_name) CelerChainIdMapping(_lineRegistryChainIds, _celerChainIds) {
        lowLevelMessager = _messageBus;
    }

    function setChainIdMap(uint256 _lineRegistryChainId, uint64 _celerChainId) external onlyOwner {
        _setChainIdMap(_lineRegistryChainId, _celerChainId);
    }

    function setToLine(uint256 _toChainId, address _toLineAddress) external onlyOwner {
        _setToLine(_toChainId, _toLineAddress);
    }

    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external onlyOwner {
        _setFromLine(_fromChainId, _fromLineAddress);
    }

    //////////////////////////////////////////
    // For sending
    //////////////////////////////////////////
    // override BaseMessageLine
    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata /*_params*/
    ) internal override {
        bytes memory celerMessage = abi.encode(_fromDappAddress, _toDappAddress, _messagePayload);

        // https://github.com/celer-network/sgn-v2-contracts/blob/1c65d5538ff8509c7e2626bb1a857683db775231/contracts/message/interfaces/IMessageBus.sol#LL122C17-L122C17
        uint256 fee = IMessageBus(lowLevelMessager).calcFee(celerMessage);

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= fee, "!fee");

        // refund fee
        if (paid > fee) {
            payable(msg.sender).transfer(paid - fee);
        }

        sendMessage(toLineLookup[_toChainId], down(_toChainId), celerMessage, fee);
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
    ) external payable override returns (ExecutionStatus) {
        (address fromDappAddress, address toDappAddress, bytes memory messagePayload) =
            abi.decode((_celerMessage), (address, address, bytes));
        uint256 fromChainId = up(_srcChainId);

        require(msg.sender == lowLevelMessager, "caller is not message bus");

        require(fromLineLookup[fromChainId] == _srcContract, "invalid source line address");

        _recv(fromChainId, fromDappAddress, toDappAddress, messagePayload);

        return ExecutionStatus.Success;
    }
}