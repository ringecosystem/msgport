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

import "@layerzerolabs/solidity-examples/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./base/BaseMessagePort.sol";
import "./base/FromPortLookup.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";

contract LayerZeroV1Port is Ownable2Step, BaseMessagePort, FromPortLookup, LayerZeroChainIdMapping, NonblockingLzApp {
    constructor(
        address dao,
        address lzEndpoint,
        string memory name,
        uint256[] memory chainIds,
        uint16[] memory lzChainIds
    ) BaseMessagePort(name) NonblockingLzApp(lzEndpoint) LayerZeroChainIdMapping(chainIds, lzChainIds) {
        _transferOwnership(dao);
    }

    function _transferOwnership(address newOwner) internal override(Ownable, Ownable2Step) {
        super._transferOwnership(newOwner);
    }

    function transferOwnership(address newOwner) public virtual override(Ownable, Ownable2Step) onlyOwner {
        super.transferOwnership(newOwner);
    }

    function setChainIdMap(uint256 chainId, uint16 lzChainId) external onlyOwner {
        _setChainIdMap(chainId, lzChainId);
    }

    function setFromPort(uint256 fromChainId, address fromPortAddress) external onlyOwner {
        _setFromPort(fromChainId, fromPortAddress);
    }

    function fromPortLookup(uint256 fromChainId) public view override returns (address) {
        uint16 lzChainId = down(fromChainId);
        return bytesToAddress(this.getTrustedRemoteAddress(lzChainId));
    }

    function bytesToAddress(bytes memory addressBytes) internal pure returns (address) {
        return address(bytes20(bytes(addressBytes)));
    }

    function _setFromPort(uint256 fromChainId, address fromPort) internal override {
        uint16 lzChainId = down(fromChainId);
        bytes memory path = abi.encodePacked(fromPort, address(this));
        trustedRemoteLookup[lzChainId] = path;
        emit SetFromPort(fromChainId, fromPort);
        emit SetTrustedRemote(lzChainId, path);
        emit SetTrustedRemoteAddress(lzChainId, abi.encodePacked(fromPort));
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        (address refund, bytes memory lzParams) = abi.decode(params, (address, bytes));
        uint16 remoteChainId = down(toChainId);

        // build layer zero message
        bytes memory layerZeroMessage = abi.encode(fromDapp, toDapp, message);

        _lzSend(
            remoteChainId,
            layerZeroMessage,
            payable(refund),
            address(0), // zro payment address
            lzParams, // adapter params
            msg.value
        );
    }

    function _storeFailedMessage(
        uint16 srcChainId,
        bytes memory srcAddress,
        uint64 nonce,
        bytes memory payload,
        bytes memory reason
    ) internal override {
        emit MessageFailed(srcChainId, srcAddress, nonce, payload, reason);
    }

    function retryMessage(uint16, bytes calldata, uint64, bytes calldata) public payable override {
        revert("!retry");
    }

    function clear(uint16 srcChainId, bytes calldata srcAddress) external {
        ILayerZeroEndpoint(lzEndpoint).forceResumeReceive(srcChainId, srcAddress);
    }

    function _nonblockingLzReceive(uint16 srcChainId, bytes memory srcAddress, uint64, /*_nonce*/ bytes memory payload)
        internal
        override
    {
        (address fromDapp, address toDapp, bytes memory message) = abi.decode(payload, (address, address, bytes));
        require(this.isTrustedRemote(srcChainId, srcAddress), "!auth");
        _recv(up(srcChainId), fromDapp, toDapp, message);
    }

    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        override
        returns (uint256)
    {
        uint16 remoteChainId = down(toChainId);
        (, bytes memory lzParams) = abi.decode(params, (address, bytes));
        bytes memory layerZeroMessage = abi.encode(msg.sender, toDapp, message);
        (uint256 nativeFee,) =
            ILayerZeroEndpoint(lzEndpoint).estimateFees(remoteChainId, address(this), layerZeroMessage, false, lzParams);
        return nativeFee;
    }
}
