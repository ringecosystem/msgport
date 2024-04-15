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
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./base/BaseMessagePort.sol";
import "./base/PeerLookup.sol";
import "../chain-id-mappings/LayerZeroV1ChainIdMapping.sol";

contract LayerZeroV1Port is Ownable2Step, BaseMessagePort, PeerLookup, LayerZeroV1ChainIdMapping {
    uint256 public constant EXTRAGAS_INPORT = 30000;

    ILayerZeroEndpoint public immutable LZ;

    modifier onlyLZ() {
        require(msg.sender == address(LZ), "!lz");
        _;
    }

    constructor(address dao, address lzv1, string memory name, uint256[] memory chainIds, uint16[] memory lzChainIds)
        BaseMessagePort(name)
        LayerZeroV1ChainIdMapping(chainIds, lzChainIds)
    {
        _transferOwnership(dao);
        LZ = ILayerZeroEndpoint(lzv1);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function setChainIdMap(uint256 chainId, uint16 lzChainId) external onlyOwner {
        _setChainIdMap(chainId, lzChainId);
    }

    function setPeer(uint256 chainId, address peer) external onlyOwner {
        _setPeer(chainId, peer);
    }

    function _getExtraGas(bytes memory lzParams) internal pure virtual returns (uint256 extraGas) {
        require(lzParams.length >= 34, "!adapterParams");
        assembly {
            extraGas := mload(add(lzParams, 34))
        }
    }

    function _checkExtraGas(bytes memory lzParams) internal pure virtual {
        uint256 extraGas = _getExtraGas(lzParams);
        require(extraGas >= EXTRAGAS_INPORT, "!extraGas");
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        (address refund, bytes memory lzParams) = abi.decode(params, (address, bytes));
        _checkExtraGas(lzParams);
        uint16 dstChainId = down(toChainId);
        bytes memory payload = abi.encode(fromDapp, toDapp, message);
        address toPort = _checkedPeerOf(toChainId);
        LZ.send{value: msg.value}(
            dstChainId, abi.encodePacked(toPort, address(this)), payload, payable(refund), address(0), lzParams
        );
    }

    function clear(uint16 srcChainId, bytes calldata srcAddress) external onlyOwner {
        LZ.forceResumeReceive(srcChainId, srcAddress);
        emit MessageFailure("Clear");
    }

    function getConfig(uint16 _version, uint16 _chainId, address, uint256 _configType)
        external
        view
        returns (bytes memory)
    {
        return LZ.getConfig(_version, _chainId, address(this), _configType);
    }

    // generic config for LayerZero user Application
    function setConfig(uint16 _version, uint16 _chainId, uint256 _configType, bytes calldata _config)
        external
        onlyOwner
    {
        LZ.setConfig(_version, _chainId, _configType, _config);
    }

    function setSendVersion(uint16 _version) external onlyOwner {
        LZ.setSendVersion(_version);
    }

    function setReceiveVersion(uint16 _version) external onlyOwner {
        LZ.setReceiveVersion(_version);
    }

    function lzReceive(uint16 srcChainId, bytes memory srcAddress, uint64, /*_nonce*/ bytes memory payload)
        internal
        onlyLZ
    {
        uint256 fromChainId = up(srcChainId);
        address fromPort = _checkedPeerOf(fromChainId);
        require(keccak256(srcAddress) == keccak256(abi.encodePacked(fromPort, address(this))), "!auth");
        (address fromDapp, address toDapp, bytes memory message) = abi.decode(payload, (address, address, bytes));
        _recv(fromChainId, fromDapp, toDapp, message);
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
        (uint256 nativeFee,) = LZ.estimateFees(remoteChainId, address(this), layerZeroMessage, false, lzParams);
        return nativeFee;
    }
}
