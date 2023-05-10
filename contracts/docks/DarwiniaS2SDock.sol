// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "../interfaces/MessageDockBase.sol";

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

contract DarwiniaS2sDock is MessageDockBase, Ownable2Step {
    address public remoteDockAddress;
    address public immutable darwiniaEndpointAddress;
    uint32 public specVersion = 6021;
    uint256 public gasLimit = 3_000_000;

    constructor(
        address msgportAddress,
        address _darwiniaEndpointAddress
    ) MessageDockBase(msgportAddress) {
        darwiniaEndpointAddress = _darwiniaEndpointAddress;
    }

    function setRemoteDockAddress(
        address _remoteDockAddress
    ) external onlyOwner {
        remoteDockAddress = _remoteDockAddress;
    }

    function setSpecVersion(uint32 _specVersion) external onlyOwner {
        specVersion = _specVersion;
    }

    function setGasLimit(uint256 _gasLimit) external onlyOwner {
        gasLimit = _gasLimit;
    }

    function getRemoteDockAddress() public view override returns (address) {
        return remoteDockAddress;
    }

    function callRemoteDockRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory messagePayload
    ) internal override returns (uint256) {
        // check specVersion is set.
        require(specVersion != 0, "!specVersion");

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

    function getRelayFee(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view override returns (uint256) {
        return IMessageEndpoint(darwiniaEndpointAddress).fee();
    }

    function getDeliveryGas(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external view override returns (uint256) {
        return 0;
    }

    function allowToRecv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _message
    ) internal override returns (bool) {
        return true;
    }
}
