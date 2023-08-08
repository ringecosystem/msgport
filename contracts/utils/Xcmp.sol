// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@darwinia/contracts-utils/contracts/ScaleCodec.sol";

abstract contract Xcmp {
    struct XcmArgs {
        uint64 refTime;
        uint64 proofSize;
        uint128 fungible;
    }

    function dispatch(bytes2 callIndex, bytes memory callParams) internal {
        (
            bool success,
            bytes memory data
        ) = 0x0000000000000000000000000000000000000401.call(
                abi.encodePacked(callIndex, callParams)
            );

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

    // just for coding style more clear
    function polkadotXcmSendCallParams(
        bytes memory d,
        bytes memory m
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(d, m);
    }

    // dest: V2(01, X1(Parachain(ParaId)))
    //       00 01  01 00        toParachain
    function dest(bytes2 toParachain) internal pure returns (bytes memory) {
        return abi.encodePacked(hex"00010100", toParachain);
    }

    function message(
        bytes2 fromParachain,
        address fromDappAddress,
        bytes memory call,
        XcmArgs memory args
    ) internal pure returns (bytes memory) {
        bytes memory fungibleEncoded = ScaleCodec.encodeUintCompact(
            args.fungible
        );
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
                ScaleCodec.encodeUintCompact(args.refTime),
                ScaleCodec.encodeUintCompact(args.proofSize),
                ScaleCodec.encodeUintCompact(call.length),
                call
            );
    }

    function buildTgtXcmpLineRecvCall(
        uint64 _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _message
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                bytes4(keccak256("recv(uint64,address,address,bytes)")),
                _fromChainId,
                _fromDappAddress,
                _toDappAddress,
                _message
            );
    }

    function xcmArgs(
        bytes memory _params
    ) internal pure returns (XcmArgs memory) {
        (uint64 refTime, uint64 proofSize, uint128 fungible) = abi.decode(
            _params,
            (uint64, uint64, uint128)
        );
        return XcmArgs(refTime, proofSize, fungible);
    }
}
