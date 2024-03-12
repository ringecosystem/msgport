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

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "ORMP/src/user/UpgradeableApplication.sol";
import "./ORMPPort.sol";

contract ORMPUpgradeableAndRetryablePort is ORMPPort, UpgradeableApplication, ReentrancyGuard {
    /// msgHash => isFailed
    mapping(bytes32 => bool) public fails;

    event MessageDispatchedFailure(
        bytes32 indexed msgHash, bytes32 msgId, uint256 fromChainId, address fromDapp, address toDapp, bytes message
    );
    event RetryFailedMessage(bytes32 indexed msgHash, bool result);
    event ClearFailedMessage(bytes32 indexed msgHash);

    constructor(address dao, address ormp, string memory name) ORMPPort(dao, ormp, name) UpgradeableApplication(ormp) {}

    function ormpSender() public view override(Application, UpgradeableApplication) returns (address) {
        return super.ormpSender();
    }

    function ormpRecver() public view override(Application, UpgradeableApplication) returns (address) {
        return super.ormpRecver();
    }

    function setAppConfig(address oracle, address relayer) external override onlyOwner {
        setSenderConfig(oracle, relayer);
        setRecverConfig(oracle, relayer);
    }

    function setSender(address ormp) external onlyOwner {
        _setSender(ormp);
    }

    function setRecver(address ormp) external onlyOwner {
        _setRecver(ormp);
    }

    function setSenderConfig(address oracle, address relayer) public onlyOwner {
        _setSenderConfig(oracle, relayer);
    }

    function setRecverConfig(address oracle, address relayer) public onlyOwner {
        _setRecverConfig(oracle, relayer);
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
}
