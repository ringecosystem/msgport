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
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./ORMPUpgradeablePort.sol";

contract ORMPUpgradeableAndRetryablePort is ORMPUpgradeablePort, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev msgHash => isDispatchedInPort.
    /// The dispatched result means dapp executed successful.
    mapping(bytes32 => bool) public dones;

    event MessageDispatchedInPort(bytes32 indexed msgHash);

    constructor(address dao, address ormp, string memory name) ORMPUpgradeablePort(dao, ormp, name) {}

    function retry(bytes calldata messageData) external payable nonReentrant {
        Message memory message = abi.decode(messageData, (Message));
        bytes32 msgHash = _checkMessage(message);
        (, address fromDapp, address toDapp, bytes memory payload) =
            abi.decode(message.encoded, (bytes4, address, address, bytes));
        _recv(message.fromChainId, fromDapp, toDapp, payload);
        _markDone(msgHash);
    }

    function clear(bytes calldata messageData) external {
        Message memory message = abi.decode(messageData, (Message));
        bytes32 msgHash = _checkMessage(message);
        (,, address toDapp,) = abi.decode(message.encoded, (bytes4, address, address, bytes));
        require(toDapp == msg.sender, "!auth");
        _clear(msgHash);
    }

    function _checkDispathed(bytes32 msgHash) internal view {
        uint256 len = historyORMPSet.length();
        for (uint256 i = 0; i < len; i++) {
            address o = historyORMPSet.at(i);
            require(IORMP(o).dones(msgHash), "!done");
        }
    }

    function _checkMessage(Message memory message) internal view returns (bytes32 msgHash) {
        msgHash = hash(message);
        _checkDispathed(msgHash);
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

    function _clear(bytes32 msgHash) internal {
        require(dones[msgHash] == false, "done");
        dones[msgHash] = true;
        emit MessageDispatchedInPort(msgHash);
    }

    function recv(address fromDapp, address toDapp, bytes calldata message) public payable override {
        super.recv(fromDapp, toDapp, message);
        bytes32 msgHash = _messageId();
        _markDone(msgHash);
    }
}
