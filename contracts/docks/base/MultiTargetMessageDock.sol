// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessagePort.sol";
import "../../interfaces/IChainIdMapping.sol";
import "./BaseMessageDock.sol";

abstract contract MultiTargetMessageDock is BaseMessageDock {
    // // tgtChainId => OutboundLane
    // mapping(uint64 => OutboundLane) public outboundLanes;
    // // srcChainId => srcDockAddress => InboundLane
    // mapping(uint64 => InboundLane) public inboundLanes;

    // constructor(
    //     address _localMsgportAddress,
    //     address _chainIdConverter
    // ) BaseMessageDock(_localMsgportAddress, _chainIdConverter) {}
}
