// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.8.17;

import "./base/BaseMessagePort.sol";
import "./base/PortLookup.sol";
import "ORMP/src/interfaces/IORMP.sol";
import "ORMP/src/user/UpgradeableApplication.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ORMPUpgradeableAndRetryablePort is
    Ownable2Step,
    UpgradeableApplication,
    BaseMessagePort,
    PortLookup,
    ReentrancyGuard
{
    /// msgHash => isFailed
    mapping(bytes32 => bool) public fails;

    event MessageDispatchedFailure(
        bytes32 indexed msgHash, bytes32 msgId, uint256 fromChainId, address fromDapp, address toDapp, bytes message
    );
    event RetryFailedMessage(bytes32 indexed msgHash, bool result);
    event ClearFailedMessage(bytes32 indexed msgHash);

    constructor(address dao, address ormp, string memory name) UpgradeableApplication(ormp) BaseMessagePort(name) {
        _transferOwnership(dao);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function setSender(address ormp) external onlyOwner {
        _setSender(ormp);
    }

    function setRecver(address ormp) external onlyOwner {
        _setRecver(ormp);
    }

    function setSenderConfig(address oracle, address relayer) external onlyOwner {
        _setSenderConfig(oracle, relayer);
    }

    function setRecverConfig(address oracle, address relayer) external onlyOwner {
        _setRecverConfig(oracle, relayer);
    }

    function setToPort(uint256 _toChainId, address _toPortAddress) external onlyOwner {
        _setToPort(_toChainId, _toPortAddress);
    }

    function setFromPort(uint256 _fromChainId, address _fromPortAddress) external onlyOwner {
        _setFromPort(_fromChainId, _fromPortAddress);
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        (uint256 gasLimit, address refund, bytes memory ormpParams) = abi.decode(params, (uint256, address, bytes));
        bytes memory encoded =
            abi.encodeWithSelector(ORMPUpgradeableAndRetryablePort.recv.selector, fromDapp, toDapp, message);
        IORMP(sender).send{value: msg.value}(
            toChainId, _checkedToPort(toChainId), gasLimit, encoded, refund, ormpParams
        );
    }

    function recv(address fromDapp, address toDapp, bytes calldata message) external payable onlyORMP {
        uint256 fromChainId = _fromChainId();
        require(_xmsgSender() == _checkedFromPort(fromChainId), "!auth");
        _recv(fromChainId, fromDapp, toDapp, message);
    }

    function retryFailedMessage(
        bytes32 msgId,
        uint256 fromChainId,
        address fromDapp,
        address toDapp,
        bytes calldata message
    ) external payable nonReentrant returns (bool success) {
        bytes32 msgHash = hashInfo(msgId, fromChainId, fromDapp, toDapp, message);
        require(fails[msgHash] == true, "!failed");
        (success,) = toDapp.call{value: msg.value}(abi.encodePacked(message, fromChainId, fromDapp));
        if (success) {
            delete fails[msgHash];
        }
        emit RetryFailedMessage(msgHash, success);
    }

    function clearFailedMessage(
        bytes32 msgId,
        uint256 fromChainId,
        address fromDapp,
        address toDapp,
        bytes calldata message
    ) external {
        bytes32 msgHash = hashInfo(msgId, fromChainId, fromDapp, toDapp, message);
        require(fails[msgHash] == true, "!failed");
        require(toDapp == msg.sender, "!auth");
        delete fails[msgHash];
        emit ClearFailedMessage(msgHash);
    }

    /// NOTE: Due to gas-related issues, it is not guaranteed that failed messages will always be stored.
    function _recv(uint256 fromChainId, address fromDapp, address toDapp, bytes memory message) internal override {
        (bool success,) = toDapp.call{value: msg.value}(abi.encodePacked(message, fromChainId, fromDapp));
        if (!success) {
            bytes32 msgId = _messageId();
            bytes32 msgHash = hashInfo(msgId, fromChainId, fromDapp, toDapp, message);
            fails[msgHash] = true;
            emit MessageDispatchedFailure(msgHash, msgId, fromChainId, fromDapp, toDapp, message);
        }
    }

    function hashInfo(bytes32 msgId, uint256 fromChainId, address fromDapp, address toDapp, bytes memory message)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(msgId, fromChainId, fromDapp, toDapp, message));
    }

    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        override
        returns (uint256)
    {
        (uint256 gasLimit,, bytes memory ormpParams) = abi.decode(params, (uint256, address, bytes));
        bytes memory encoded =
            abi.encodeWithSelector(ORMPUpgradeableAndRetryablePort.recv.selector, msg.sender, toDapp, message);
        return IORMP(sender).fee(toChainId, address(this), gasLimit, encoded, ormpParams);
    }
}
