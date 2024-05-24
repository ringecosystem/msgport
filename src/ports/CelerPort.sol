// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./base/BaseMessagePort.sol";
import "./base/PeerLookup.sol";
import "../chain-id-mappings/CelerChainIdMapping.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";
import "../utils/Utils.sol";

contract CelerPort is BaseMessagePort, PeerLookup, CelerChainIdMapping, MessageSenderApp, MessageReceiverApp {
    address public remotePortAddress;
    address public immutable lowLevelMessager;

    constructor(
        address _messageBus,
        string memory _name,
        uint256[] memory _portRegistryChainIds,
        uint64[] memory _celerChainIds
    ) BaseMessagePort(_name) CelerChainIdMapping(_portRegistryChainIds, _celerChainIds) {
        lowLevelMessager = _messageBus;
    }

    function setChainIdMap(uint256 _portRegistryChainId, uint64 _celerChainId) external onlyOwner {
        _setChainIdMap(_portRegistryChainId, _celerChainId);
    }

    function setPeer(uint256 chainId, address peer) external onlyOwner {
        _setPeer(chainId, peer);
    }

    //////////////////////////////////////////
    // For sending
    //////////////////////////////////////////
    // override BaseMessagePort
    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata /*_params*/
    ) internal override returns (bytes32) {
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

        sendMessage(_checkedPeerOf(_toChainId), down(_toChainId), celerMessage, fee);

        return bytes32(0);
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

        require(_checkedPeerOf(fromChainId) == _srcContract, "invalid source port address");

        _recv(bytes32(0), fromChainId, fromDappAddress, toDappAddress, messagePayload);

        return ExecutionStatus.Success;
    }
}
