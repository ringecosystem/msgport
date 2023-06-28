// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/SingleTargetMessageDock.sol";

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

contract DarwiniaS2sDock is SingleTargetMessageDock, Ownable2Step {
    address public immutable darwiniaEndpointAddress;

    constructor(
        address _localMsgportAddress,
        address _chainIdConverter,
        uint64 _remoteChainId,
        address _remoteDockAddress,
        address _darwiniaEndpointAddress
    )
        SingleTargetMessageDock(
            _localMsgportAddress,
            _chainIdConverter,
            _remoteChainId,
            _remoteDockAddress
        )
    {
        darwiniaEndpointAddress = _darwiniaEndpointAddress;
    }

    function _callRemoteRecvForSingle(
        address _fromDappAddress,
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

        IMessageEndpoint(darwiniaEndpointAddress).remoteExecute{
            value: msg.value
        }(specVersion, remoteDockAddress, recvCall, gasLimit);
    }

    function _approveToRecvForSingle(
        address /*_fromDappAddress*/,
        address /*_toDappAddress*/,
        bytes memory /*_message*/
    ) internal pure override returns (bool) {
        return true;
    }
}
