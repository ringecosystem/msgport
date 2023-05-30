// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/BaseMessageDock.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../utils/Utils.sol";

contract AxelarDock is BaseMessageDock, AxelarExecutable, Ownable {
    IAxelarGasService public immutable gasService;

    uint64 public nextNonce;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        address _gateway,
        address _gasReceiver
    )
        BaseMessageDock(_localMsgportAddress, _chainIdConverter)
        AxelarExecutable(_gateway)
    {
        gasService = IAxelarGasService(_gasReceiver);
    }

    function setChainIdConverter(address _chainIdConverter) external onlyOwner {
        setChainIdConverterInternal(_chainIdConverter);
    }

    function chainIdUp(string memory _chainId) public view returns (uint64) {
        return chainIdMapping.up(bytes(_chainId));
    }

    function chainIdDown(uint64 _chainId) public view returns (string memory) {
        return string(chainIdMapping.down(_chainId));
    }

    function addRemoteDock(
        uint64 _remoteChainId,
        address _remoteDockAddress
    ) external onlyOwner {
        addRemoteDockInternal(_remoteChainId, _remoteDockAddress);
    }

    function approveToRecv(
        uint64 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal override returns (bool) {
        // because dock is called by low-level gateway, we need to check the sender is correct.
        if (msg.sender != address(gateway)) {
            return false;
        } else {
            return true;
        }
    }

    function callRemoteRecv(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDockAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        bytes memory axelarMessage = abi.encode(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        string memory toChainId = chainIdDown(_toChainId);
        string memory toDockAddress = Utils.addressToHexString(_toDockAddress);

        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{value: msg.value}(
                address(this),
                toChainId,
                toDockAddress,
                axelarMessage,
                msg.sender
            );
        }

        gateway.callContract(toChainId, toDockAddress, axelarMessage);

        return nextNonce++;
    }

    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        (
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode(payload_, (address, address, bytes));
        recv(
            chainIdUp(sourceChain_),
            Utils.hexStringToAddress(sourceAddress_),
            fromDappAddress,
            toDappAddress,
            messagePayload
        );
    }
}
