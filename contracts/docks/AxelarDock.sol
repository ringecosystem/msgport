// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/MessageDockBase.sol";
import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract AxelarDock is MessageDockBase, AxelarExecutable {
    string public sourceChain;
    string public sourceAddress;
    string public destinationChain;
    IAxelarGasService public immutable gasService;

    address public remoteDockAddress;
    uint64 public nextNonce;

    constructor(
        address _msgportAddress,
        address _gateway,
        address _gasReceiver
    ) MessageDockBase(_msgportAddress) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasReceiver);
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
        bytes memory messagePayload
    ) internal override returns (uint256) {
        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{value: msg.value}(
                address(this),
                destinationChain,
                Strings.toHexString(uint256(uint160(remoteDockAddress)), 20),
                messagePayload,
                msg.sender
            );
        }

        gateway.callContract(
            destinationChain,
            Strings.toHexString(uint256(uint160(remoteDockAddress)), 20),
            abi.encodeWithSignature(
                "recv(address,address,address,bytes)",
                address(this),
                _fromDappAddress,
                _toDappAddress,
                messagePayload
            )
        );

        return nextNonce++;
    }

    function getRemoteDockAddress() public virtual override returns (address) {
        return remoteDockAddress;
    }
}
