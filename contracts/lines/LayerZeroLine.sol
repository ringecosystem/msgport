// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "../utils/Utils.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@layerzerolabs/solidity-examples/contracts/interfaces/ILayerZeroEndpoint.sol";

contract LayerZeroLine is BaseMessageLine, NonblockingLzApp {
    address public immutable chainIdMappingAddress;

    constructor(
        address _localLineRegistryAddress,
        address _chainIdMappingAddress,
        address _lzEndpointAddress,
        Metadata memory _metadata
    ) BaseMessageLine(_localLineRegistryAddress, _lzEndpointAddress, _metadata) NonblockingLzApp(_lzEndpointAddress) {
        chainIdMappingAddress = _chainIdMappingAddress;
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
        bytes memory _params
    ) internal override {
        // set remote line address
        uint16 remoteChainId = LayerZeroChainIdMapping(chainIdMappingAddress).down(_toChainId);

        // build layer zero message
        bytes memory layerZeroMessage = abi.encode(_fromDappAddress, _toDappAddress, _messagePayload);

        _lzSend(
            remoteChainId,
            layerZeroMessage,
            payable(msg.sender), // refund to lineRegistry
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
        uint64 srcChainId = LayerZeroChainIdMapping(chainIdMappingAddress).up(_srcChainId);
        address srcLineAddress = Utils.bytesToAddress(_srcAddress);

        (address fromDappAddress, address toDappAddress, bytes memory messagePayload) =
            abi.decode(_payload, (address, address, bytes));

        require(fromLineAddressLookup[srcChainId] == srcLineAddress, "invalid source line address");

        _recv(srcChainId, fromDappAddress, toDappAddress, messagePayload);
    }

    function estimateFee(
        uint64 _toChainId, // Dest lineRegistry chainId
        bytes calldata _payload,
        bytes calldata _params
    ) external view virtual override returns (uint256) {
        uint16 remoteChainId = LayerZeroChainIdMapping(chainIdMappingAddress).down(_toChainId);
        bytes memory layerZeroMessage = abi.encode(address(0), address(0), _payload);
        (uint256 nativeFee,) = ILayerZeroEndpoint(localMessagingContractAddress).estimateFees(
            remoteChainId, address(this), layerZeroMessage, false, _params
        );
        return nativeFee;
    }
}
