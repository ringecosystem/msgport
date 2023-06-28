// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessagePort.sol";
import "../../interfaces/IChainIdMapping.sol";

abstract contract BaseMessageDock {
    struct OutboundLane {
        uint64 toChainId;
        address toDockAddress;
    }

    struct InboundLane {
        uint64 fromChainId;
        address fromDockAddress;
    }

    IMessagePort public immutable LOCAL_MSGPORT;
    IChainIdMapping public chainIdMapping;

    constructor(address _localMsgportAddress, address _chainIdConverter) {
        LOCAL_MSGPORT = IMessagePort(_localMsgportAddress);
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    function getLocalChainId() public view returns (uint64) {
        return LOCAL_MSGPORT.getLocalChainId();
    }

    function setChainIdConverterInternal(address _chainIdConverter) internal {
        chainIdMapping = IChainIdMapping(_chainIdConverter);
    }

    function _requireCalledByMsgport() internal view virtual {
        // check this is called by local msgport
        require(
            msg.sender == address(LOCAL_MSGPORT),
            "not allowed to be called by others except local msgport"
        );
    }

    // called by local msgport
    function send(
        address /*_fromDappAddress*/,
        uint64 /*_toChainId*/,
        address /*_toDappAddress*/,
        bytes memory /*_payload*/,
        bytes memory /*_params*/
    ) public payable virtual {
        _requireCalledByMsgport();
    }

    // called by remote dock through low level messaging contract or self
    function recv(
        address _fromDappAddress,
        InboundLane memory _inboundLane,
        address _toDappAddress,
        bytes memory _message
    ) public virtual {
        // call local msgport to receive message
        LOCAL_MSGPORT.recv(
            _inboundLane.fromChainId,
            _fromDappAddress,
            _toDappAddress,
            _message
        );
    }
}
