// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interfaces/BaseMessageDock.sol";
import "@darwinia/contracts-utils/contracts/ScaleCodec.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../utils/Utils.sol";

// TODO: extract abstract base contract
contract DarwiniaXcmpDock is BaseMessageDock, Ownable2Step {
    address public remoteDockAddress;

    bytes2 public immutable POLKADOT_XCM_SEND_CALL_INDEX;
    address public constant DISPATCH =
        0x0000000000000000000000000000000000000401;

    // remote chainId => next nonce
    mapping(uint64 => uint64) public nonces;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        bytes2 _polkadotXcmSendCallIndex
    ) BaseMessageDock(_localMsgportAddress, _chainIdConverter) {
        POLKADOT_XCM_SEND_CALL_INDEX = _polkadotXcmSendCallIndex;
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

    function chainIdUp(bytes2 _chainId) public view returns (uint64) {
        return chainIdMapping.up(abi.encodePacked(_chainId));
    }

    function chainIdDown(uint64 _chainId) public view returns (bytes2) {
        return bytes2(chainIdMapping.down(_chainId));
    }

    function approveToRecv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal pure override returns (bool) {
        return true;
    }

    function callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        (uint64 refTime, uint64 proofSize, uint128 fungible) = abi.decode(
            _params,
            (uint64, uint64, uint128)
        );

        bytes memory call = abi.encodeWithSignature(
            "recv(uint256,address,address,address,bytes)",
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        transactOnParachain(
            _fromDappAddress,
            _outboundLane.toChainId,
            call,
            refTime,
            proofSize,
            fungible
        );
    }

    /////////////////////////////////////////
    // Lib
    /////////////////////////////////////////
    event PolkadotXcmSendCallEvent(
        bytes call,
        bytes message,
        bytes polkadotXcmSend
    );

    function transactOnParachain(
        address fromDappAddress,
        uint64 toChainId,
        bytes memory call,
        uint64 refTime,
        uint64 proofSize,
        uint128 fungible
    ) internal {
        bytes memory message = buildXcmPayload(
            chainIdDown(getLocalChainId()),
            fromDappAddress,
            call,
            refTime,
            proofSize,
            fungible
        );

        bytes memory polkadotXcmSendCall = abi.encodePacked(
            // call index of `polkadotXcm.send`
            POLKADOT_XCM_SEND_CALL_INDEX,
            // dest: V2(01, X1(Parachain(ParaId)))
            hex"00010100",
            chainIdDown(toChainId),
            message
        );

        emit PolkadotXcmSendCallEvent(call, message, polkadotXcmSendCall);

        (bool success, bytes memory data) = DISPATCH.call(polkadotXcmSendCall);

        if (!success) {
            Utils.revertWithMessage(data, "Dispatch failed");
        }
    }

    function buildXcmPayload(
        bytes2 fromParachain,
        address fromDappAddress,
        bytes memory call,
        uint64 refTime,
        uint64 proofSize,
        uint128 fungible
    ) internal pure returns (bytes memory) {
        bytes memory fungibleEncoded = ScaleCodec.encodeUintCompact(fungible);
        return
            abi.encodePacked(
                // XcmVersion + Instruction Length
                hex"0310",
                // DescendOrigin
                // --------------------------
                hex"0b010300",
                fromDappAddress,
                // WithdrawAsset
                // --------------------------
                hex"000400010200",
                fromParachain,
                hex"040500",
                fungibleEncoded,
                // BuyExecution
                // --------------------------
                hex"1300010200",
                fromParachain,
                hex"040500",
                fungibleEncoded,
                hex"00", // weight limit
                // Transact
                // --------------------------
                hex"0601",
                ScaleCodec.encodeUintCompact(refTime),
                ScaleCodec.encodeUintCompact(proofSize),
                ScaleCodec.encodeUintCompact(call.length),
                call
            );
    }
}
