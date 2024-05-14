// SPDX-License-Identifier: MIT
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
        returns (bytes32 msgId)
    {
        (address refund, bytes memory lzParams) = abi.decode(params, (address, bytes));
        _checkExtraGas(lzParams);
        uint16 dstChainId = down(toChainId);
        bytes memory payload = abi.encode(fromDapp, toDapp, message);
        address toPort = _checkedPeerOf(toChainId);
        LZ.send{value: msg.value}(
            dstChainId, abi.encodePacked(toPort, address(this)), payload, payable(refund), address(0), lzParams
        );
        uint64 nonce = LZ.getOutboundNonce(dstChainId, address(this));
        return keccak256(abi.encodePacked(dstChainId, address(this), toPort, nonce));
    }

    function clear(uint16 srcChainId, bytes calldata srcAddress) external onlyOwner {
        LZ.forceResumeReceive(srcChainId, srcAddress);
        uint64 nonce = LZ.getInboundNonce(srcChainId, srcAddress);
        bytes32 msgId = keccak256(abi.encodePacked(LZ.getChainId(), srcAddress, nonce));
        emit MessageRecv(msgId, false, "Clear");
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

    function lzReceive(uint16 srcChainId, bytes memory srcAddress, uint64 nonce, bytes memory payload)
        internal
        onlyLZ
    {
        uint256 fromChainId = up(srcChainId);
        address fromPort = _checkedPeerOf(fromChainId);
        require(keccak256(srcAddress) == keccak256(abi.encodePacked(fromPort, address(this))), "!auth");
        (address fromDapp, address toDapp, bytes memory message) = abi.decode(payload, (address, address, bytes));
        bytes32 msgId = keccak256(abi.encodePacked(LZ.getChainId(), srcAddress, nonce));
        _recv(msgId, fromChainId, fromDapp, toDapp, message);
    }

    function fee(uint256 toChainId, address fromDapp, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        override
        returns (uint256)
    {
        uint16 remoteChainId = down(toChainId);
        (, bytes memory lzParams) = abi.decode(params, (address, bytes));
        bytes memory layerZeroMessage = abi.encode(fromDapp, toDapp, message);
        (uint256 nativeFee,) = LZ.estimateFees(remoteChainId, address(this), layerZeroMessage, false, lzParams);
        return nativeFee;
    }
}
