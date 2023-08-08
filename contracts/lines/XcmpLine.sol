// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../utils/Xcmp.sol";

contract XcmpLine is BaseMessageLine, Xcmp, Ownable2Step {
    bytes2 public immutable polkadotXcmSendCallIndex;

    constructor(
        address _localMsgportAddress,
        bytes2 _polkadotXcmSendCallIndex,
        Metadata memory _metadata
    ) BaseMessageLine(_localMsgportAddress, address(0x0), _metadata) {
        polkadotXcmSendCallIndex = _polkadotXcmSendCallIndex;
    }

    function _send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        uint64 fromChainId = LOCAL_MSGPORT.getLocalChainId();

        // build the call data to be transact on the target chain:
        //   TgtXcmpLine.recv(_fromChainId, _fromDappAddress, _toDappAddress, _message)
        bytes memory theCall = buildTgtXcmpLineRecvCall(
            fromChainId,
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        // prepare the para ids
        bytes2 fromParaId = chainIdMapping(fromChainId);
        bytes2 toParaId = chainIdMapping(_toChainId);

        // send the XCM `message` to `dest` through dispatching the `polkadotXcm.send` call
        dispatch(
            polkadotXcmSendCallIndex,
            polkadotXcmSendCallParams(
                dest(toParaId),
                message(fromParaId, _fromDappAddress, theCall, xcmArgs(_params))
            )
        );
    }

    function chainIdMapping(uint64 _chainId) public pure returns (bytes2) {
        if (_chainId == 46) {
            return 0x1111;
        } else if (_chainId == 44) {
            return 0x2222;
        } else {
            revert("Unsupported chainId");
        }
    }
}
