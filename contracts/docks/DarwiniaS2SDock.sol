// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "../interfaces/MessageDock.sol";

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

contract DarwiniaS2sDock is MessageDock, Ownable2Step {
    address public remoteDockAddress;
    address public immutable darwiniaEndpointAddress;

    constructor(
        address _localMsgportAddress,
        uint _remoteChainId,
        address _darwiniaEndpointAddress
    ) MessageDock(_localMsgportAddress, _remoteChainId) {
        darwiniaEndpointAddress = _darwiniaEndpointAddress;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) external onlyOwner {
        remoteDockAddress = _remoteDockAddress;
    }

    function getRemoteDockAddress() public view override returns (address) {
        return remoteDockAddress;
    }

    function callRemoteDockRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload,
        bytes memory _params
    ) internal override returns (uint256) {
        (uint32 specVersion, uint256 gasLimit) = abi.decode(
            _params,
            (uint32, uint256)
        );

        bytes memory recvCall = abi.encodeWithSignature(
            "recv(address,address,address,bytes)",
            address(this),
            _fromDappAddress,
            _toDappAddress,
            messagePayload
        );

        return
            IMessageEndpoint(darwiniaEndpointAddress).remoteExecute{
                value: msg.value
            }(specVersion, remoteDockAddress, recvCall, gasLimit);
    }

    function allowToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _message
    ) internal override returns (bool) {
        return true;
    }
}
