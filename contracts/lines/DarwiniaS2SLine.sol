// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";

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

contract DarwiniaS2sLine is BaseMessageLine, Ownable2Step {

    constructor(
        address _localMsgportAddress,
        address _darwiniaEndpointAddress,
        uint64 _remoteChainId,
        address _remoteLineAddress,
        Metadata memory _metadata
    ) BaseMessageLine(_localMsgportAddress, _darwiniaEndpointAddress, _metadata) {
        // add outbound and inbound lane
        _addToLine(_remoteChainId, _remoteLineAddress);
        _addFromLine(_remoteChainId, _remoteLineAddress);
    }

    function _callRemoteRecv(
        address _fromDappAddress,
        uint64 _toChainId,
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

        IMessageEndpoint(localMessagingContractAddress).remoteExecute{
            value: msg.value
        }(specVersion, toLineAddressLookup[_toChainId], recvCall, gasLimit);
    }
}
