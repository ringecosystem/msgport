// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/AbstractMessageChannel.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IOutboundLane.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IFeeMarket.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/ICrossChainFilter.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaChannel is
    AbstractMessageChannel,
    ICrossChainFilter,
    Ownable2Step
{
    address public remoteChannelAddress;
    address public immutable outboundLane;
    address public immutable inboundLane;
    address public immutable feeMarket;

    constructor(
        address msgportAddress,
        address _outboundLane,
        address _inboundLane,
        address _feeMarket
    ) AbstractMessageChannel(msgportAddress) {
        outboundLane = _outboundLane;
        inboundLane = _inboundLane;
        feeMarket = _feeMarket;
    }

    function setRemoteChannelAddress(
        address _remoteChannelAddress
    ) external onlyOwner {
        remoteChannelAddress = _remoteChannelAddress;
    }

    //////////////////////////////////////////
    // override AbstractMessageChannel
    //////////////////////////////////////////
    function getRemoteChannelAddress() public view override returns (address) {
        return remoteChannelAddress;
    }

    function getRelayFee(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view override returns (uint256) {
        return IFeeMarket(feeMarket).market_fee();
    }

    function getDeliveryGas(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view override returns (uint256) {
        return 0;
    }

    // For sending
    function callRemoteChannelRecv(
        address _remoteChannelAddress,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal override returns (uint256) {
        return
            IOutboundLane(outboundLane).send_message{value: msg.value}(
                _remoteChannelAddress,
                abi.encodeWithSignature(
                    "recv(address,address,bytes)",
                    _fromDappAddress,
                    _toDappAddress,
                    messagePayload
                )
            );
    }

    // For receiving
    function permitted(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
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
        // check remote channel address is set.
        // this check is not necessary, but it can provide an more understandable err.
        require(remoteChannelAddress != address(0), "!remote channel");

        return sourceAccount == remoteChannelAddress;
    }
}
