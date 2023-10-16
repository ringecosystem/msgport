// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/FromLineLookup.sol";
import "../utils/Utils.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/interfaces/ILayerZeroEndpoint.sol";

contract LayerZeroLine is BaseMessageLine, FromLineLookup, LayerZeroChainIdMapping, NonblockingLzApp {
    address public immutable lowLevelMessager;

    constructor(
        address _lzEndpointAddress,
        Metadata memory _metadata,
        uint256[] memory _lineRegistryChainIds,
        uint16[] memory _lzChainIds
    )
        BaseMessageLine(_metadata)
        NonblockingLzApp(_lzEndpointAddress)
        LayerZeroChainIdMapping(_lineRegistryChainIds, _lzChainIds)
    {
        lowLevelMessager = _lzEndpointAddress;
    }

    function setChainIdMap(uint256 _lineRegistryChainId, uint16 _lzChainId) external onlyOwner {
        _setChainIdMap(_lineRegistryChainId, _lzChainId);
    }

    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external onlyOwner {
        _setFromLine(_fromChainId, _fromLineAddress);
    }

    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata _params
    ) internal override {
        // set remote line address
        uint16 remoteChainId = down(_toChainId);

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
        uint256 srcChainId = up(_srcChainId);
        address srcLineAddress = Utils.bytesToAddress(_srcAddress);

        (address fromDappAddress, address toDappAddress, bytes memory messagePayload) =
            abi.decode(_payload, (address, address, bytes));

        require(fromLineLookup[srcChainId] == srcLineAddress, "invalid source line address");

        _recv(srcChainId, fromDappAddress, toDappAddress, messagePayload);
    }

    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
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
