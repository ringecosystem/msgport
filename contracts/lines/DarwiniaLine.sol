// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IOutboundLane.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IFeeMarket.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/ICrossChainFilter.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaLine is BaseMessageLine, ICrossChainFilter, Ownable2Step {
    address public immutable outboundLane;
    address public immutable inboundLane;
    IFeeMarket public immutable feeMarket;

    constructor(
        address _localMsgportAddress,
        uint64 _remoteChainId,
        address _remoteLineAddress,
        address _outboundLane,
        address _inboundLane,
        address _feeMarket
    ) BaseMessageLine(_localMsgportAddress, _inboundLane) {
        // add outbound and inbound lane
        _addOutboundLaneInternal(_remoteChainId, _remoteLineAddress);
        _addInboundLaneInternal(_remoteChainId, _remoteLineAddress);
        //
        outboundLane = _outboundLane;
        inboundLane = _inboundLane;
        //
        feeMarket = IFeeMarket(_feeMarket);
    }

    function getLineInfo() external pure returns (string memory) {
        return "DarwiniaLCMP";
    }

    //////////////////////////////////////////
    // override BaseMessageLine
    //////////////////////////////////////////
    // For sending
    function _callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory /*_params*/
    ) internal override {
        // estimate fee on chain
        uint256 fee = feeMarket.market_fee();

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= fee, "!fee");

        // refund fee
        if (paid > fee) {
            payable(msg.sender).transfer(paid - fee);
        }

        IOutboundLane(outboundLane).send_message{value: fee}(
            _outboundLane.toLineAddress,
            abi.encodeWithSignature(
                "recv(uint256,address,address,address,bytes)",
                getLocalChainId(),
                address(this),
                _fromDappAddress,
                _toDappAddress,
                _messagePayload
            )
        );
    }

    //////////////////////////////////////////
    // implement ICrossChainFilter
    //////////////////////////////////////////
    function cross_chain_filter(
        uint32 /*bridgedChainPosition*/,
        uint32 /*bridgedLanePosition*/,
        address sourceAccount,
        bytes calldata /*payload*/
    ) external view returns (bool) {
        address remoteLineAddress = inboundLanes[getLocalChainId()]
            .fromLineAddress;
        // check remote line address is set.
        // this check is not necessary, but it can provide an more understandable err.
        require(remoteLineAddress != address(0), "!remote line");

        return sourceAccount == remoteLineAddress;
    }
}
