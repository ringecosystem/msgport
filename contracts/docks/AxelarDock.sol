// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/MessageDockBase.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract AxelarDock is MessageDockBase, AxelarExecutable, Ownable2Step {
    string public sourceChain;
    string public destinationChain;
    IAxelarGasService public immutable gasService;

    address public remoteDockAddress;
    uint64 public nextNonce;

    constructor(
        address _msgportAddress,
        address _gateway,
        address _gasReceiver,
        string memory _sourceChain,
        string memory _destinationChain
    ) MessageDockBase(_msgportAddress) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasReceiver);
        sourceChain = _sourceChain;
        destinationChain = _destinationChain;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) external onlyOwner {
        remoteDockAddress = _remoteDockAddress;
    }

    function allowToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal virtual override returns (bool) {
        return true;
    }

    function callRemoteDockRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        bytes memory axelarMessage = abi.encode(
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{value: msg.value}(
                address(this),
                destinationChain,
                Strings.toHexString(uint256(uint160(remoteDockAddress)), 20),
                axelarMessage,
                msg.sender
            );
        }

        gateway.callContract(
            destinationChain,
            Strings.toHexString(uint256(uint160(remoteDockAddress)), 20),
            axelarMessage
        );

        return nextNonce++;
    }

    function getRemoteDockAddress() public virtual override returns (address) {
        return remoteDockAddress;
    }

    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        (
            address srcDockAddress,
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode(payload_, (address, address, address, bytes));
        recv(srcDockAddress, fromDappAddress, toDappAddress, messagePayload);
    }
}
