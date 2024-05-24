// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessagePort.sol";
import "./base/PeerLookup.sol";
import "../chain-id-mappings/AxelarChainIdMapping.sol";
import "../utils/Utils.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract AxelarPort is BaseMessagePort, PeerLookup, AxelarChainIdMapping, AxelarExecutable, Ownable2Step {
    IAxelarGasService public immutable GAS_SERVICE;

    constructor(
        address _gateway,
        address _gasReceiver,
        string memory _name,
        uint256[] memory _portRegistryChainIds,
        string[] memory _axelarChainIds
    ) BaseMessagePort(_name) AxelarExecutable(_gateway) AxelarChainIdMapping(_portRegistryChainIds, _axelarChainIds) {
        GAS_SERVICE = IAxelarGasService(_gasReceiver);
    }

    function setChainIdMap(uint256 _portRegistryChainId, string calldata _axelarChainId) external onlyOwner {
        _setChainIdMap(_portRegistryChainId, _axelarChainId);
    }

    function setPeer(uint256 chainId, address peer) external onlyOwner {
        _setPeer(chainId, peer);
    }

    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata /*_params*/
    ) internal override returns (bytes32) {
        bytes memory axelarMessage = abi.encode(_fromDappAddress, _toDappAddress, _messagePayload);

        string memory toChainId = down(_toChainId);
        string memory toPortAddress = Utils.addressToHexString(_checkedPeerOf(_toChainId));

        if (msg.value > 0) {
            GAS_SERVICE.payNativeGasForContractCall{value: msg.value}(
                address(this), toChainId, toPortAddress, axelarMessage, msg.sender
            );
        }

        gateway.callContract(toChainId, toPortAddress, axelarMessage);

        return bytes32(0);
    }

    function _execute(string calldata sourceChain_, string calldata sourceAddress_, bytes calldata payload_)
        internal
        override
    {
        (address fromDappAddress, address toDappAddress, bytes memory messagePayload) =
            abi.decode(payload_, (address, address, bytes));

        uint256 fromChainId = up(sourceChain_);
        require(_checkedPeerOf(fromChainId) == Utils.hexStringToAddress(sourceAddress_), "invalid source port address");

        _recv(bytes32(0), fromChainId, fromDappAddress, toDappAddress, messagePayload);
    }
}
