
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../utils/XcmUtils.sol";

// PolkadotXcm.send()
contract XcmpLine is BaseMessageLine, Ownable2Step {

  bytes2 public immutable SRC_PARAID;
  bytes2 public immutable TGT_PARAID;
  bytes2 public immutable POLKADOT_XCM_PALLET_SEND_CALL_INDEX;
  address public constant DISPATCH =
    0x0000000000000000000000000000000000000401;

  constructor(
    address _localMsgportAddress,
    address _chainIdMappingAddress,
    bytes2 _srcParaId,
    bytes2 _tgtParaId,
    bytes2 _sendCallIndex,
    Metadata memory _metadata
  ) BaseMessageLine(_localMsgportAddress, _inboundLane, _metadata) {
    SRC_PARAID = _srcParaId;
    TGT_PARAID = _tgtParaId;
    POLKADOT_XCM_PALLET_SEND_CALL_INDEX = _sendCallIndex;
  }

  function send(
    address _fromDappAddress,
    uint64 _toChainId,
    address _toDappAddress,
    bytes memory _payload,
    bytes memory _params
  ) external payable {
    XcmUtils.transactOnParachain(
      POLKADOT_XCM_PALLET_SEND_CALL_INDEX,
      SRC_PARAID,
      this.address,
      TGT_PARAID,
      _payload
    )
  }

  function estimateFee(
    uint64 _toChainId, // Dest msgport chainId
    bytes calldata _payload,
    bytes calldata _params
  ) external view returns (uint256) {

  }

}
