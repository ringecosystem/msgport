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
    /// @dev msgHash => isDispathedInPort.
    mapping(bytes32 => bool) public dones;

    event MessageDispatchedInPort(bytes32 indexed msgHash);
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

    function retryFailedMessage(Message calldata message) external payable nonReentrant {
        bytes32 msgHash = _checkMessage(message);
        (, address fromDapp, address toDapp, bytes memory payload) =
            abi.decode(message.encoded, (bytes4, address, address, bytes));
        _recv(message.fromChainId, fromDapp, toDapp, payload);
        _markDone(msgHash);
    }

    function _checkMessage(Message calldata message) internal view returns (bytes32 msgHash) {
        msgHash = hash(message);
        require(IORMP(ormpRecver()).dones(msgHash) == true, "!done");
        require(LOCAL_CHAINID() == message.toChainId, "!toChainId");
        require(address(this) == message.to, "!to");
        uint256 fromChainId = message.fromChainId;
        require(message.from == _checkedFromPort(fromChainId), "!xAuth");
    }

    function _markDone(bytes32 msgHash) internal {
        require(dones[msgHash] == false, "done");
        dones[msgHash] = true;
        emit MessageDispatchedInPort(msgHash);
    }

    function recv(address fromDapp, address toDapp, bytes memory message) public payable override {
        super.recv(fromDapp, toDapp, message);
        bytes32 msgHash = _messageId();
        _markDone(msgHash);
    }

    function clearFailedMessage(Message calldata message) external {
        bytes32 msgHash = _checkMessage(message);
        (,, address toDapp,) = abi.decode(message.encoded, (bytes4, address, address, bytes));
        require(toDapp == msg.sender, "!auth");
        _clear(msgHash);
    }

    function _clear(bytes32 msgHash) internal {
        require(dones[msgHash] == false, "done");
        dones[msgHash] = true;
        emit ClearFailedMessage(msgHash);
    }
}
