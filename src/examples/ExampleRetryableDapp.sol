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
import "ORMP/src/Common.sol";
import "../interfaces/IMessagePortExt.sol";
import "./ExampleReceiverDapp.sol";

contract ExampleRetryableDapp is ExampleReceiverDapp, ReentrancyGuard {
    uint256 public immutable FROM_CHAINID;

    constructor(address port, address dapp, uint256 fromChainId) ExampleReceiverDapp(port, dapp) {
        FROM_CHAINID = fromChainId;
    }

    // function retryFailedMessage(Message calldata message) external payable nonReentrant {
    //     msgHash = hash(message);
    //     require(IMessagePortExt(PORT).checkDeliveried(msgHash), "!delivery");
    //     require(IMessagePortExt(PORT).checkCompleted(msgHash) == false, "completed");
    //     require(message.toChainId == block.chainid, "!toChainId");
    //     require(message.to == PORT, "!to");
    //     require(message.fromChainId == FROM_CHAINID, "!fromChainId");
    //     require(message.from == IMessagePortExt(PORT).fromPortLookup(FROM_CHAINID), "!port");
    //     (bytes4, address fromDapp, address toDapp, bytes memory payload) =
    //         abi.decode(message.encoded, (bytes4, address, address, bytes));
    //     require(fromDapp == DAPP, "!fromDapp");
    //     require(toDapp == address(this), "!toDapp");
    //     (bytes4 sig, bytes memory params) = abi.decode(payload, (bytes4, bytes));
    //     require(sig == ExampleReceiverDapp.xxx.selector, "!sig");
    //     // redo xxx.
    //     emit DappMessageRecv(FROM_CHAINID, DAPP, PORT, params);
    // }
}
