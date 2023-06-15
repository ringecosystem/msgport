// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../interfaces/BaseMessageDock.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "../utils/Utils.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";
import "../utils/GNSPSBytesLib.sol";

contract LayerZeroDock is
    BaseMessageDock,
    NonblockingLzApp,
    LayerZeroChainIdMapping
{
    using GNSPSBytesLib for bytes;

    address public lzEndpointAddress;
    mapping(uint64 => uint64) public nonces;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        address _lzEndpoint
    )
        BaseMessageDock(_localMsgportAddress, _chainIdConverter)
        NonblockingLzApp(_lzEndpoint)
    {
        lzEndpointAddress = _lzEndpoint;
    }

    function setChainIdConverter(address _chainIdConverter) external onlyOwner {
        setChainIdConverterInternal(_chainIdConverter);
    }

    function newOutboundLane(
        uint64 _toChainId,
        address _toDockAddress
    ) external override onlyOwner {
        addOutboundLaneInternal(_toChainId, _toDockAddress);
    }

    function newInboundLane(
        uint64 _fromChainId,
        address _fromDockAddress
    ) external override onlyOwner {
        addInboundLaneInternal(_fromChainId, _fromDockAddress);
    }

    function chainIdUp(uint16 _chainId) public view returns (uint64) {
        return chainIdMapping.up(Utils.uint16ToBytes(_chainId));
    }

    function chainIdDown(uint64 _chainId) public view returns (uint16) {
        return Utils.bytesToUint16(chainIdMapping.down(_chainId));
    }

    function approveToRecv(
        address /*_fromDappAddress*/,
        InboundLane memory /*_inboundLane*/,
        address /*_toDappAddress*/,
        bytes memory /*_messagePayload*/
    ) internal pure override returns (bool) {
        // because dock is called by low-level gateway, we need to check the sender is correct.
        // if (msg.sender != address(lzEndpointAddress)) {
        //     return false;
        // } else {
        //     return true;
        // }
        return true;
    }

    function callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        // set remote dock address
        uint16 remoteChainId = chainIdDown(_outboundLane.toChainId);
        trustedRemoteLookup[remoteChainId] = abi.encodePacked(
            _outboundLane.toDockAddress,
            address(this)
        );

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
        uint64 srcChainId = chainIdUp(_srcChainId);
        address srcDockAddress = Utils.bytesToAddress(_srcAddress);

        (
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode(_payload, (address, address, bytes));

        InboundLane memory inboundLane = inboundLanes[srcChainId];
        require(
            inboundLane.fromDockAddress == srcDockAddress,
            "invalid source dock address"
        );

        recv(fromDappAddress, inboundLane, toDappAddress, messagePayload);
    }

    event Debug(bytes);

    function lzReceive(
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        uint64 _nonce,
        bytes calldata _payload
    ) public override {
        // lzReceive must be called by the endpoint for security
        require(
            _msgSender() == address(lzEndpoint),
            "LayerZeroDock: invalid endpoint caller"
        );

        bytes memory trustedRemote = trustedRemoteLookup[_srcChainId];
        // if will still block the message pathway from (srcChainId, srcAddress). should not receive message from untrusted remote.
        require(
            _srcAddress.length == trustedRemote.length &&
                trustedRemote.length > 0 &&
                keccak256(_srcAddress) == keccak256(trustedRemote),
            "LzApp: invalid source sending contract"
        );

        _blockingLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
    }
}
