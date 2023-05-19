// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "../interfaces/BaseMessageDock.sol";
import "@darwinia/contracts-utils/contracts/ScaleCodec.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaXcmpDock is BaseMessageDock, Ownable2Step {
    address public remoteDockAddress;

    bytes2 public immutable SRC_PARAID;
    bytes2 public immutable TGT_PARAID;
    bytes2 public immutable POLKADOT_XCM_SEND_CALL_INDEX;
    address public constant DISPATCH =
        0x0000000000000000000000000000000000000401;

    constructor(
        address _localMsgportAddress,
        uint _remoteChainId,
        bytes2 _srcParaId,
        bytes2 _tgtParaId,
        bytes2 _polkadotXcmSendCallIndex
    ) BaseMessageDock(_localMsgportAddress, _remoteChainId) {
        SRC_PARAID = _srcParaId;
        TGT_PARAID = _tgtParaId;
        POLKADOT_XCM_SEND_CALL_INDEX = _polkadotXcmSendCallIndex;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) public override onlyOwner {
        remoteDockAddress = _remoteDockAddress;
    }

    function approveToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal override returns (bool) {
        return true;
    }

    function callRemoteRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        (uint64 refTime, uint64 proofSize, uint128 fungible) = abi.decode(
            _params,
            (uint64, uint64, uint128)
        );

        bytes memory call = abi.encodeWithSignature(
            "recv(address,address,address,bytes)",
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        transactOnParachain(
            _fromDappAddress,
            call,
            refTime,
            proofSize,
            fungible
        );
        return 0;
    }

    function getRemoteDockAddress() public override returns (address) {
        return remoteDockAddress;
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
        bytes memory call,
        uint64 refTime,
        uint64 proofSize,
        uint128 fungible
    ) internal {
        bytes memory message = buildXcmPayload(
            SRC_PARAID,
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
            TGT_PARAID,
            message
        );

        emit PolkadotXcmSendCallEvent(call, message, polkadotXcmSendCall);

        (bool success, bytes memory data) = DISPATCH.call(polkadotXcmSendCall);

        if (!success) {
            if (data.length > 0) {
                assembly {
                    let resultDataSize := mload(data)
                    revert(add(32, data), resultDataSize)
                }
            } else {
                revert("!dispatch");
            }
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
