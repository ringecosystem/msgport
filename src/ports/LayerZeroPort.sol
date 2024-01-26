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

import "./base/BaseMessagePort.sol";
import "./base/FromPortLookup.sol";
import "../utils/Utils.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";

contract LayerZeroPort is BaseMessagePort, FromPortLookup, LayerZeroChainIdMapping, NonblockingLzApp {
    address public immutable lowLevelMessager;

    constructor(
        address _lzEndpointAddress,
        string memory _name,
        uint256[] memory _portRegistryChainIds,
        uint16[] memory _lzChainIds
    )
        BaseMessagePort(_name)
        NonblockingLzApp(_lzEndpointAddress)
        LayerZeroChainIdMapping(_portRegistryChainIds, _lzChainIds)
    {
        lowLevelMessager = _lzEndpointAddress;
    }

    function setChainIdMap(uint256 _portRegistryChainId, uint16 _lzChainId) external onlyOwner {
        _setChainIdMap(_portRegistryChainId, _lzChainId);
    }

    function setFromPort(uint256 _fromChainId, address _fromPortAddress) external onlyOwner {
        _setFromPort(_fromChainId, _fromPortAddress);
    }

    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata _params
    ) internal override {
        // set remote port address
        uint16 remoteChainId = down(_toChainId);

        // build layer zero message
        bytes memory layerZeroMessage = abi.encode(_fromDappAddress, _toDappAddress, _messagePayload);

        _lzSend(
            remoteChainId,
            layerZeroMessage,
            payable(msg.sender), // refund to portRegistry
            address(0x0), // zro payment address
            _params, // adapter params
            msg.value
        );
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64, /*_nonce*/
        bytes memory _payload
    ) internal virtual override {
        uint256 srcChainId = up(_srcChainId);
        address srcPortAddress = Utils.bytesToAddress(_srcAddress);

        (address fromDappAddress, address toDappAddress, bytes memory messagePayload) =
            abi.decode(_payload, (address, address, bytes));

        require(fromPortLookup[srcChainId] == srcPortAddress, "invalid source port address");

        _recv(srcChainId, fromDappAddress, toDappAddress, messagePayload);
    }

    function fee(uint256 toChainId, address, bytes calldata message, bytes calldata params)
        external
        view
        override
        returns (uint256)
    {
        uint16 remoteChainId = down(toChainId);
        bytes memory layerZeroMessage = abi.encode(address(0), address(0), message);
        (uint256 nativeFee,) = ILayerZeroEndpoint(lowLevelMessager).estimateFees(
            remoteChainId, address(this), layerZeroMessage, false, params
        );
        return nativeFee;
    }
}
