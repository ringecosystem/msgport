// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/MessageDock.sol";
import "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";

contract LayerZeroDock is MessageDock, NonblockingLzApp {
    uint16 public immutable LZ_SRC_CHAIN_ID;
    uint16 public immutable LZ_TGT_CHAIN_ID;
    address public remoteDockAddress;
    uint64 public nextNonce = 0;

    constructor(
        address _localMsgportAddress,
        uint _remoteChainId,
        address _lzEndpoint,
        uint16 _lzSrcChainId,
        uint16 _lzTgtChainId
    )
        MessageDock(_localMsgportAddress, _remoteChainId)
        NonblockingLzApp(_lzEndpoint)
    {
        LZ_SRC_CHAIN_ID = _lzSrcChainId;
        LZ_TGT_CHAIN_ID = _lzTgtChainId;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) public override onlyOwner {
        remoteDockAddress = _remoteDockAddress;
        trustedRemoteLookup[LZ_TGT_CHAIN_ID] = abi.encodePacked(
            _remoteDockAddress,
            address(this)
        );
    }

    function approveToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal virtual override returns (bool) {
        return true;
    }

    function callRemoteRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual override returns (uint256) {
        bytes memory layerZeroMessage = abi.encode(
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        _lzSend(
            LZ_TGT_CHAIN_ID,
            layerZeroMessage,
            payable(msg.sender),
            address(0x0),
            bytes(""),
            msg.value
        );

        return nextNonce++;
    }

    function getRemoteDockAddress() public virtual override returns (address) {
        return remoteDockAddress;
    }

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal virtual override {
        require(_srcChainId == LZ_SRC_CHAIN_ID, "Invalid chainId");
        (
            address srcDockAddress,
            address fromDappAddress,
            address toDappAddress,
            bytes memory messagePayload
        ) = abi.decode((_payload), (address, address, address, bytes));
        recv(srcDockAddress, fromDappAddress, toDappAddress, messagePayload);
    }
}
