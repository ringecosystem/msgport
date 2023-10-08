// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "../chain-id-mappings/AxelarChainIdMapping.sol";
import "../utils/Utils.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract AxelarLine is BaseMessageLine, AxelarExecutable, Ownable2Step {
    IAxelarGasService public immutable GAS_SERVICE;

    address public immutable chainIdMappingAddress;

    constructor(address _chainIdMappingAddress, address _gateway, address _gasReceiver, Metadata memory _metadata)
        BaseMessageLine(_gateway, _metadata)
        AxelarExecutable(_gateway)
    {
        chainIdMappingAddress = _chainIdMappingAddress;
        GAS_SERVICE = IAxelarGasService(_gasReceiver);
    }

    function addToLine(uint64 _toChainId, address _toLineAddress) external onlyOwner {
        _addToLine(_toChainId, _toLineAddress);
    }

    function addFromLine(uint64 _fromChainId, address _fromLineAddress) external onlyOwner {
        _addFromLine(_fromChainId, _fromLineAddress);
    }

    function _send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory /*_params*/
    ) internal override {
        bytes memory axelarMessage = abi.encode(_fromDappAddress, _toDappAddress, _messagePayload);

        string memory toChainId = AxelarChainIdMapping(chainIdMappingAddress).down(_toChainId);
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

        uint64 fromChainId = AxelarChainIdMapping(chainIdMappingAddress).up(sourceChain_);
        require(fromLineLookup[fromChainId] == Utils.hexStringToAddress(sourceAddress_), "invalid source line address");

        _recv(fromChainId, fromDappAddress, toDappAddress, messagePayload);
    }
}
