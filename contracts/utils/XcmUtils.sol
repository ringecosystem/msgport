pragma solidity ^0.8.9;

import "@darwinia/contracts-utils/contracts/ScaleCodec.sol";

library XcmUtils {
  struct XcmArgs {
    uint64 refTime;
    uint64 proofSize;
    uint128 fungible;
  }

  /** 
   */
  function transactOnParachain(
    bytes2 polkadotXcmSendCallIndex,
    bytes2 fromParachain,
    address fromDappAddress,
    bytes2 toParachain,
    bytes memory theCall,
    XcmArgs memory xcmArgs
  ) internal {
    dispatch(
      polkadotXcmSendCallIndex,
      polkadotXcmSendCallParams(
        dest(toParachain),
        message(fromParachain, fromDapp, theCall, xcmArgs)
      )
    )
  }

  function dispatch(bytes2 callIndex, bytes memory callParams) internal {
    (bool success, bytes memory data) = 0x0000000000000000000000000000000000000401.call(
      abi.encodePacked(
        callIndex,
        callParams 
      )
    )

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

  function polkadotXcmSendCallParams(bytes memory dest, bytes memory message) internal pure returns (bytes memory) { 
    return abi.encodePacked(
      dest,
      message
    );
  }

  // dest: V2(01, X1(Parachain(ParaId)))
  //       00 01  01 00        toParachain
  function dest(bytes2 toParachain) internal pure returns (bytes memory) {
    return abi.encodePacked(
      hex"00010100", 
      toParachain
    );
  }

  function message(
    bytes2 fromParachain,
    address fromDappAddress,
    bytes memory call,
    XcmArgs memory xcmArgs
  ) internal pure returns (bytes memory) {
    bytes memory fungibleEncoded = ScaleCodec.encodeUintCompact(xcmArgs.fungible);
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
      ScaleCodec.encodeUintCompact(xcmArgs.refTime),
      ScaleCodec.encodeUintCompact(xcmArgs.proofSize),
      ScaleCodec.encodeUintCompact(call.length),
      call
    );
  }
}
