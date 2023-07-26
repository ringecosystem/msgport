// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "../utils/Utils.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";

contract LayerZeroLine is BaseMessageLine, NonblockingLzApp {
    address public immutable chainIdMappingAddress;

    constructor(
        address _localMsgportAddress,
        address _chainIdMappingAddress,
        address _lzEndpoingAddress,
        Metadata memory _metadata
    )
        BaseMessageLine(_localMsgportAddress, _lzEndpoingAddress, _metadata)
        NonblockingLzApp(_lzEndpoingAddress)
    {
        chainIdMappingAddress = _chainIdMappingAddress;
    }

    function addToLine(
        uint64 _toChainId,
        address _toLineAddress
    ) external onlyOwner {
        _addToLine(_toChainId, _toLineAddress);
    }

    function addFromLine(
        uint64 _fromChainId,
        address _fromLineAddress
    ) external onlyOwner {
        _addFromLine(_fromChainId, _fromLineAddress);
    }

    function _callRemoteRecv(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        // set remote line address
        uint16 remoteChainId = LayerZeroChainIdMapping(chainIdMappingAddress).down(_toChainId);

        // build layer zero message
        bytes memory layerZeroMessage = abi.encode(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        _lzSend(
            remoteChainId,
            layerZeroMessage,
            payable(msg.sender), // refund to msgport
            address(0x0), // zro payment address
            _params, // adapter params
            msg.value
        );
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 /*_nonce*/,
        bytes memory _payload
    ) internal virtual override {
        uint64 srcChainId = LayerZeroChainIdMapping(chainIdMappingAddress).up(_srcChainId);
        address srcLineAddress = Utils.bytesToAddress(_srcAddress);

        (
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode(_payload, (address, address, bytes));

        require(
            fromLineAddressLookup[srcChainId] == srcLineAddress,
            "invalid source line address"
        );

        recv(srcChainId, fromDappAddress, toDappAddress, messagePayload);
    }
}
