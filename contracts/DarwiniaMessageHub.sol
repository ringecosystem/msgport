// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./interfaces/IMessageReceiver.sol";
import "./interfaces/IMsgport.sol";
import "@darwinia/contracts-utils/contracts/ScaleCodec.sol";

contract DarwiniaMessageHub is IMessageReceiver {
    bytes2 public immutable DARWINIA_PARAID;
    bytes2 public immutable SEND_CALL_INDEX;
    address public constant DISPATCH =
        0x0000000000000000000000000000000000000401;

    address public immutable MSGPORT_ADDRESS;

    constructor(
        bytes2 _darwiniaParaId,
        bytes2 _sendCallIndex,
        address _msgportAddress
    ) {
        DARWINIA_PARAID = _darwiniaParaId;
        SEND_CALL_INDEX = _sendCallIndex;
        MSGPORT_ADDRESS = _msgportAddress;
    }

    //////////////////////////
    // To Parachain
    //////////////////////////
    // message format:
    //  - paraId: bytes2
    //  - call: bytes
    //  - refTime: uint64
    //  - proofSize: uint64
    //  - fungible: uint128
    function recv(address _fromDappAddress, bytes calldata _message) external {
        (
            bytes2 paraId,
            bytes memory call,
            uint64 refTime,
            uint64 proofSize,
            uint128 fungible
        ) = abi.decode(_message, (bytes2, bytes, uint64, uint64, uint128));
        require(
            msg.sender == MSGPORT_ADDRESS,
            "DarwiniaMessageHub: only accept message from msgport"
        );

        transactOnParachain(
            paraId,
            _fromDappAddress,
            call,
            refTime,
            proofSize,
            fungible
        );
    }

    function transactOnParachain(
        bytes2 paraId,
        address fromDappAddress,
        bytes memory call,
        uint64 refTime,
        uint64 proofSize,
        uint128 fungible
    ) internal {
        bytes memory message = buildXcmPayload(
            DARWINIA_PARAID,
            fromDappAddress,
            call,
            refTime,
            proofSize,
            fungible
        );

        bytes memory polkadotXcmSendCall = abi.encodePacked(
            // call index of `polkadotXcm.send`
            SEND_CALL_INDEX,
            // dest: V2(01, X1(Parachain(ParaId)))
            hex"00010100",
            paraId,
            message
        );

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

    //////////////////////////
    // To Ethereum
    //////////////////////////
    function send(
        address _toDappAddress, // address on Ethereum
        bytes calldata _messagePayload,
        uint256 _fee
    ) external payable returns (uint256 nonce) {
        uint256 paid = msg.value;

        require(paid >= _fee, "!fee");
        if (paid > _fee) {
            // refund fee to Dapp.
            payable(msg.sender).transfer(paid - _fee);
        }

        return
            IMsgport(MSGPORT_ADDRESS).send{value: _fee}(
                81,
                _toDappAddress,
                _messagePayload,
                _fee,
                hex""
            );
    }
}
