// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../interfaces/MessageDockBase.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IOutboundLane.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IFeeMarket.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/ICrossChainFilter.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaDock is MessageDockBase, ICrossChainFilter, Ownable2Step {
    address public remoteDockAddress;
    address public immutable outboundLane;
    address public immutable inboundLane;
    address public immutable feeMarket;

    constructor(
        address msgportAddress,
        address _outboundLane,
        address _inboundLane,
        address _feeMarket
    ) MessageDockBase(msgportAddress) {
        outboundLane = _outboundLane;
        inboundLane = _inboundLane;
        feeMarket = _feeMarket;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) external onlyOwner {
        remoteDockAddress = _remoteDockAddress;
    }

    //////////////////////////////////////////
    // override MessageDockBase
    //////////////////////////////////////////
    function getRemoteDockAddress() public view override returns (address) {
        return remoteDockAddress;
    }

    // For sending
    function callRemoteDockRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        return
            IOutboundLane(outboundLane).send_message{value: msg.value}(
                remoteDockAddress,
                abi.encodeWithSignature(
                    "recv(address,address,address,bytes)",
                    address(this),
                    _fromDappAddress,
                    _toDappAddress,
                    messagePayload
                )
            );
    }

    // For receiving
    function allowToRecv(
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
        // check remote dock address is set.
        // this check is not necessary, but it can provide an more understandable err.
        require(remoteDockAddress != address(0), "!remote dock");

        return sourceAccount == remoteDockAddress;
    }
}
