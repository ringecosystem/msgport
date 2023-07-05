// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageDock.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

interface IMessageEndpoint {
    function remoteExecute(
        uint32 specVersion,
        address callReceiver,
        bytes calldata callPayload,
        uint256 gasLimit
    ) external payable returns (uint256);

    function fee() external view returns (uint128);
}

contract DarwiniaS2sDock is BaseMessageDock, Ownable2Step {
    IChainIdMapping public chainIdMapping;

    constructor(
        address _localMsgportAddress,
        address _darwiniaEndpointAddress,
        address _chainIdMapping,
        uint64 _remoteChainId,
        address _remoteDockAddress
    ) BaseMessageDock(_localMsgportAddress, _darwiniaEndpointAddress) {
        chainIdMapping = IChainIdMapping(_chainIdMapping);
        // add outbound and inbound lane
        _addOutboundLaneInternal(_remoteChainId, _remoteDockAddress);
        _addInboundLaneInternal(_remoteChainId, _remoteDockAddress);
    }

    function getProviderName() external pure returns (string memory) {
        return "DarwiniaS2S";
    }

    function _callRemoteRecv(
        address _fromDappAddress,
        OutboundLane memory _outboundLane,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        (uint32 specVersion, uint256 gasLimit) = abi.decode(
            _params,
            (uint32, uint256)
        );

        bytes memory recvCall = abi.encodeWithSignature(
            "recv(uint256,address,address,address,bytes)",
            getLocalChainId(),
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        IMessageEndpoint(localLevelMessagingContractAddress).remoteExecute{
            value: msg.value
        }(specVersion, _outboundLane.toDockAddress, recvCall, gasLimit);
    }

    function _approveToRecv(
        address /*_fromDappAddress*/,
        InboundLane memory /*_inboundLane*/,
        address /*_toDappAddress*/,
        bytes memory /*_messagePayload*/
    ) internal pure override returns (bool) {
        return true;
    }
}
