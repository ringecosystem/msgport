// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/BaseMessageDock.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";
import "../utils/Utils.sol";
import "../chain-id-mappings/LayerZeroChainIdMapping.sol";

contract LayerZeroDock is
    BaseMessageDock,
    NonblockingLzApp,
    LayerZeroChainIdMapping
{
    address public lzEndpointAddress;
    uint64 public nextNonce;

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

    function chainIdUp(uint16 _chainId) public view returns (uint64) {
        return chainIdMapping.up(Utils.uint16ToBytes(_chainId));
    }

    function chainIdDown(uint64 _chainId) public view returns (uint16) {
        return Utils.bytesToUint16(chainIdMapping.down(_chainId));
    }

    function addRemoteDock(
        uint64 _remoteChainId,
        address _remoteDockAddress
    ) external onlyOwner {
        addRemoteDockInternal(_remoteChainId, _remoteDockAddress);
    }

    function approveToRecv(
        uint64 _fromChainId,
        address _fromDockAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal override returns (bool) {
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
        uint64 _toChainId,
        address _toDockAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        // set remote dock address
        uint16 remoteChainId = chainIdDown(_toChainId);
        trustedRemoteLookup[remoteChainId] = abi.encodePacked(
            _toDockAddress,
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

        return nextNonce++;
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal virtual override {
        uint256 srcChainId = chainIdUp(_srcChainId);
        address srcDockAddress = Utils.bytesToAddress(_srcAddress);
        require(
            remoteDockExists(_srcChainId, srcDockAddress),
            "Invalid remote dock address"
        );

        (
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode(_payload, (address, address, bytes));
        recv(
            chainIdUp(_srcChainId),
            srcDockAddress,
            fromDappAddress,
            toDappAddress,
            messagePayload
        );
    }
}
