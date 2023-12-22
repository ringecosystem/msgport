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

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "../interfaces/ILineRegistry.sol";
import "../interfaces/ILineMetadata.sol";
import "../interfaces/IMessageLine.sol";
import "../user/Application.sol";

/// @title MultiLine
/// @notice Send message by multi message line.
contract MultiLine is Ownable2Step, Application, BaseMessageLine, LineLookup {
    /// @dev RemoteCallArgs
    /// @param names Line names selected to send message.
    /// @param params Params correspond with the selected lines.
    /// @param fees Fees correspond with the selected lines.
    /// @param salt Salt is for unique identify the line message id with LineMsg info.
    /// @param expiration Expiration timestamp for the message.
    /// @param threshold Threshold for execute the message.
    struct RemoteCallArgs {
        string[] names;
        bytes[] params;
        uint256[] fees;
        uint256 salt;
        uint256 expiration;
        uint256 threshold;
    }

    struct MultiSendArgs {
        string[] names;
        uint256 toChainId;
        address toDapp;
        bytes message;
        bytes[] params;
        uint256[] fees;
        uint256 salt;
        uint256 expiration;
        uint256 threshold;
    }

    struct LineMsg {
        uint256 fromChainId;
        uint256 toChainId;
        address fromDapp;
        address toDapp;
        uint256 salt;
        bytes message;
        uint256 expiration;
        uint256 threshold;
    }

    mapping(bytes32 lineMsgId => bool done) public doneOf;
    mapping(bytes32 lineMsgId => uint256 deliveryCount) public countOf;
    // protect msg repeat by underwood
    mapping(bytes32 lineMsgId => mapping(address line => bool isDeliveried)) public deliverifyOf;

    ILineRegistry public immutable REGISTRY;

    event LineMessageSent(bytes32 indexed lineMsgId, string[] names, LineMsg lineMsg);
    event LineMessageConfirmation(bytes32 indexed lineMsgId, string name);
    event LineMessageExpired(bytes32 indexed lineMsgId);
    event LineMessageExecution(bytes32 indexed lineMsgId);

    constructor(address dao, address registry, string memory name) BaseMessageLine(name) {
        _transferOwnership(dao);
        REGISTRY = ILineRegistry(registry);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function setToLine(uint256 _toChainId, address _toLineAddress) external onlyOwner {
        _setToLine(_toChainId, _toLineAddress);
    }

    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external onlyOwner {
        _setFromLine(_fromChainId, _fromLineAddress);
    }

    function _toLine(uint256 toChainId) internal view returns (address l) {
        l = toLineLookup[toChainId];
        require(l != address(0), "!toLine");
    }

    function _fromLine(uint256 fromChainId) internal view returns (address) {
        return fromLineLookup[fromChainId];
    }

    function _send(address, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        RemoteCallArgs memory args = abi.decode(params, (RemoteCallArgs));
        multiSend(
            MultiSendArgs(
                args.names,
                toChainId,
                toDapp,
                message,
                args.params,
                args.fees,
                args.salt,
                args.expiration,
                args.threshold
            )
        );
    }

    function multiSend(MultiSendArgs memory args) public payable {
        require(args.toChainId != LOCAL_CHAINID(), "!toChainId");

        address fromDapp = msg.sender;
        LineMsg memory lineMsg = LineMsg({
            fromChainId: LOCAL_CHAINID(),
            toChainId: args.toChainId,
            fromDapp: fromDapp,
            toDapp: args.toDapp,
            salt: args.salt,
            message: args.message,
            expiration: args.expiration,
            threshold: args.threshold
        });
        bytes32 lineMsgId = hash(lineMsg);
        bytes memory encoded = abi.encodeWithSelector(MultiLine.multiRecv.selector, lineMsg);

        uint256 totalFee = 0;
        for (uint256 i = 0; i < args.names.length; i++) {
            string memory name = args.names[i];
            uint256 fee = args.fees[i];
            address line = REGISTRY.getLine(name);
            require(line != address(0), "!name");
            IMessageLine(line).send{value: fee}(args.toChainId, _toLine(args.toChainId), encoded, args.params[i]);
            totalFee += fee;
        }

        require(totalFee == msg.value, "!fees");
        emit LineMessageSent(lineMsgId, args.names, lineMsg);
    }

    function multiRecv(LineMsg calldata lineMsg) external payable {
        address line = _msgLine();
        require(REGISTRY.isTrustedLine(line), "!line");
        uint256 fromChainId = _fromChainId();
        require(LOCAL_CHAINID() == lineMsg.toChainId, "!toChainId");
        require(fromChainId == lineMsg.fromChainId, "!fromChainId");
        require(fromChainId != LOCAL_CHAINID(), "!fromChainId");
        require(_xmsgSender() == _fromLine(fromChainId), "!xmsgSender");
        bytes32 lineMsgId = hash(lineMsg);
        require(deliverifyOf[lineMsgId][line] == false, "deliveried");
        deliverifyOf[lineMsgId][line] = true;
        ++countOf[lineMsgId];

        emit LineMessageConfirmation(lineMsgId, ILineMetadata(line).name());

        if (block.timestamp > lineMsg.expiration) {
            emit LineMessageExpired(lineMsgId);
            return;
        }

        require(doneOf[lineMsgId] == false, "done");
        if (countOf[lineMsgId] >= lineMsg.threshold) {
            doneOf[lineMsgId] = true;
            _recv(lineMsg.fromChainId, lineMsg.fromDapp, lineMsg.toDapp, lineMsg.message);
            emit LineMessageExecution(lineMsgId);
        }
    }

    function hash(LineMsg memory lineMsg) public pure returns (bytes32) {
        return keccak256(abi.encode(lineMsg));
    }
}
