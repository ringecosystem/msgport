// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.8.9;

import "./base/BaseMessagePort.sol";
import "./base/PortLookup.sol";
import "../chain-id-mappings/CelerChainIdMapping.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageSenderApp.sol";
import "sgn-v2-contracts/contracts/message/framework/MessageReceiverApp.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "sgn-v2-contracts/contracts/message/interfaces/IMessageBus.sol";
import "../utils/Utils.sol";

contract CelerPort is BaseMessagePort, PortLookup, CelerChainIdMapping, MessageSenderApp, MessageReceiverApp {
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

    function setToPort(uint256 _toChainId, address _toPortAddress) external onlyOwner {
        _setToPort(_toChainId, _toPortAddress);
    }

    function setFromPort(uint256 _fromChainId, address _fromPortAddress) external onlyOwner {
        _setFromPort(_fromChainId, _fromPortAddress);
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

        sendMessage(_checkedToPort(_toChainId), down(_toChainId), celerMessage, fee);
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

        require(_checkedFromPort(fromChainId) == _srcContract, "invalid source port address");

        _recv(fromChainId, fromDappAddress, toDappAddress, messagePayload);

        return ExecutionStatus.Success;
    }
}
