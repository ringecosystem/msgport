// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/SingleTargetMessageDock.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IOutboundLane.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IFeeMarket.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/ICrossChainFilter.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaDock is
    SingleTargetMessageDock,
    ICrossChainFilter,
    Ownable2Step
{
    address public immutable outboundLane;
    address public immutable inboundLane;
    IFeeMarket public immutable feeMarket;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        uint256 _remoteChainId,
        address _remoteDockAddress,
        address _outboundLane,
        address _inboundLane,
        address _feeMarket
    )
        SingleTargetMessageDock(
            _localMsgportAddress,
            _chainIdConverter,
            _remoteChainId,
            _remoteDockAddress
        )
    {
        outboundLane = _outboundLane;
        inboundLane = _inboundLane;
        feeMarket = IFeeMarket(_feeMarket);
    }

    //////////////////////////////////////////
    // override BaseMessageDock
    //////////////////////////////////////////
    // For sending
    function callRemoteRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        // estimate fee on chain
        uint256 fee = feeMarket.market_fee();

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= fee, "!fee");

        // refund fee
        if (paid > fee) {
            payable(msg.sender).transfer(paid - fee);
        }

        return
            IOutboundLane(outboundLane).send_message{value: msg.value}(
                remoteDockAddress,
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

    // For receiving
    function approveToRecvForSingle(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) internal view override returns (bool) {
        require(msg.sender == inboundLane, "!inboundLane");
        return true;
    }

    //////////////////////////////////////////
    // implement ICrossChainFilter
    //////////////////////////////////////////
    function cross_chain_filter(
        uint32 bridgedChainPosition,
        uint32 bridgedLanePosition,
        address sourceAccount,
        bytes calldata payload
    ) external view returns (bool) {
        // check remote dock address is set.
        // this check is not necessary, but it can provide an more understandable err.
        require(remoteDockAddress != address(0), "!remote dock");

        return sourceAccount == remoteDockAddress;
    }
}
