// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./base/BaseMessageDock.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IOutboundLane.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IFeeMarket.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/ICrossChainFilter.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaDock is BaseMessageDock, ICrossChainFilter, Ownable2Step {
    address public immutable outboundLane;
    address public immutable inboundLane;
    IFeeMarket public immutable feeMarket;

    constructor(
        address _localMsgportAddress,
        uint64 _remoteChainId,
        address _remoteDockAddress,
        address _outboundLane,
        address _inboundLane,
        address _feeMarket
    ) BaseMessageDock(_localMsgportAddress, _inboundLane) {
        // add outbound and inbound lane
        _addOutboundLaneInternal(_remoteChainId, _remoteDockAddress);
        _addInboundLaneInternal(_remoteChainId, _remoteDockAddress);
        //
        outboundLane = _outboundLane;
        inboundLane = _inboundLane;
        //
        feeMarket = IFeeMarket(_feeMarket);
    }

    function getProviderName() external pure returns (string memory) {
        return "DarwiniaLCMP";
    }

    //////////////////////////////////////////
    // override BaseMessageDock
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
            _outboundLane.toDockAddress,
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
    function _approveToRecv(
        address /*_fromDappAddress*/,
        InboundLane memory /*_inboundLane*/,
        address /*_toDappAddress*/,
        bytes memory /*_messagePayload*/
    ) internal pure override returns (bool) {
        return true;
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
        address remoteDockAddress = inboundLanes[getLocalChainId()]
            .fromDockAddress;
        // check remote dock address is set.
        // this check is not necessary, but it can provide an more understandable err.
        require(remoteDockAddress != address(0), "!remote dock");

        return sourceAccount == remoteDockAddress;
    }
}
