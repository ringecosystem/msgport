// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/ToLineLookup.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

interface IMessageEndpoint {
    function remoteExecute(uint32 specVersion, address callReceiver, bytes calldata callPayload, uint256 gasLimit)
        external
        payable
        returns (uint256);

    function fee() external view returns (uint128);
}

contract DarwiniaS2sLine is BaseMessageLine, ToLineLookup, Ownable2Step {
    address public immutable lowLevelMessager;

    constructor(
        address _darwiniaEndpointAddress,
        uint256 _remoteChainId,
        address _remoteLineAddress,
        Metadata memory _metadata
    ) BaseMessageLine(_metadata) {
        // add outbound and inbound lane
        _setToLine(_remoteChainId, _remoteLineAddress);
        lowLevelMessager = _darwiniaEndpointAddress;
    }

    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal override {
        (uint32 specVersion, uint256 gasLimit) = abi.decode(_params, (uint32, uint256));

        bytes memory recvCall = abi.encodeWithSignature(
            "recv(uint256,address,address,address,bytes)",
            LOCAL_CHAINID(),
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        IMessageEndpoint(lowLevelMessager).remoteExecute{value: msg.value}(
            specVersion, toLineLookup[_toChainId], recvCall, gasLimit
        );
    }
}
