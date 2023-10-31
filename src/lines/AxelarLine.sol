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

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "../chain-id-mappings/AxelarChainIdMapping.sol";
import "../utils/Utils.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract AxelarLine is BaseMessageLine, LineLookup, AxelarChainIdMapping, AxelarExecutable, Ownable2Step {
    IAxelarGasService public immutable GAS_SERVICE;

    constructor(
        address _gateway,
        address _gasReceiver,
        string memory _name,
        uint256[] memory _lineRegistryChainIds,
        string[] memory _axelarChainIds
    ) BaseMessageLine(_name) AxelarExecutable(_gateway) AxelarChainIdMapping(_lineRegistryChainIds, _axelarChainIds) {
        GAS_SERVICE = IAxelarGasService(_gasReceiver);
    }

    function setChainIdMap(uint256 _lineRegistryChainId, string calldata _axelarChainId) external onlyOwner {
        _setChainIdMap(_lineRegistryChainId, _axelarChainId);
    }

    function setToLine(uint256 _toChainId, address _toLineAddress) external onlyOwner {
        _setToLine(_toChainId, _toLineAddress);
    }

    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external onlyOwner {
        _setFromLine(_fromChainId, _fromLineAddress);
    }

    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata /*_params*/
    ) internal override {
        bytes memory axelarMessage = abi.encode(_fromDappAddress, _toDappAddress, _messagePayload);

        string memory toChainId = down(_toChainId);
        string memory toLineAddress = Utils.addressToHexString(toLineLookup[_toChainId]);

        if (msg.value > 0) {
            GAS_SERVICE.payNativeGasForContractCall{value: msg.value}(
                address(this), toChainId, toLineAddress, axelarMessage, msg.sender
            );
        }

        gateway.callContract(toChainId, toLineAddress, axelarMessage);
    }

    function _execute(string calldata sourceChain_, string calldata sourceAddress_, bytes calldata payload_)
        internal
        override
    {
        (address fromDappAddress, address toDappAddress, bytes memory messagePayload) =
            abi.decode(payload_, (address, address, bytes));

        uint256 fromChainId = up(sourceChain_);
        require(fromLineLookup[fromChainId] == Utils.hexStringToAddress(sourceAddress_), "invalid source line address");

        _recv(fromChainId, fromDappAddress, toDappAddress, messagePayload);
    }
}
