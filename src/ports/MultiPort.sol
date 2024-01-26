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
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./base/BaseMessagePort.sol";
import "./base/PortLookup.sol";
import "../interfaces/IPortRegistry.sol";
import "../interfaces/IPortMetadata.sol";
import "../interfaces/IMessagePort.sol";
import "../user/Application.sol";

/// @title MultiPort
/// @notice Send message by multi message port.
contract MultiPort is Ownable2Step, Application, BaseMessagePort, PortLookup {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @dev RemoteCallArgs
    /// @param ports Message ports selected for send the message.
    /// @param nonce Nonce for portMsgId uniqueness.
    /// @param expiration The message considered be stale after the expiration in the number seconds.
    /// @param params Params correspond with the selected ports.
    /// @param fees Fees correspond with the selected ports.
    struct RemoteCallArgs {
        address[] ports;
        uint256 nonce;
        uint256 expiration;
        bytes[] params;
        uint256[] fees;
    }

    struct PortMsg {
        uint256 fromChainId;
        uint256 toChainId;
        address fromDapp;
        address toDapp;
        uint256 nonce;
        uint256 expiration;
        bytes message;
    }

    /// @dev Threshold for multi port confirmation to execute msg.
    uint256 public threshold;
    /// @dev Trusted ports managed by dao.
    EnumerableSet.AddressSet private _trustedPorts;

    mapping(bytes32 portMsgId => bool done) public doneOf;
    mapping(bytes32 portMsgId => uint256 deliveryCount) public countOf;
    // protect msg repeat by msgport
    mapping(bytes32 portMsgId => mapping(address port => bool isDeliveried)) public deliverifyOf;

    /// @dev The maximum duration that a message's expiration parameter can be set to
    uint256 public constant MAX_MESSAGE_EXPIRATION = 30 days;

    event SetThreshold(uint256 threshold);
    event PortMessageSent(bytes32 indexed portMsgId, PortMsg portMsg, bool[] sentResult);
    event PortMessageConfirmation(bytes32 indexed portMsgId, address port);
    event PortMessageExpired(bytes32 indexed portMsgId);
    event PortMessageExecution(bytes32 indexed portMsgId);

    constructor(address dao, uint256 threshold_, string memory name) BaseMessagePort(name) {
        _transferOwnership(dao);
        _setThreshold(threshold_);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function setThreshold(uint256 threshold_) external onlyOwner {
        _setThreshold(threshold_);
    }

    function _setThreshold(uint256 threshold_) internal {
        require(threshold_ > 0, "!threshold");
        threshold = threshold_;
        emit SetThreshold(threshold_);
    }

    function addTrustedPort(address port) external onlyOwner {
        require(_trustedPorts.add(port), "!add");
    }

    function rmTrustedPort(address port) external onlyOwner {
        require(_trustedPorts.remove(port), "!rm");
    }

    function trustedPorts() public view returns (address[] memory) {
        return _trustedPorts.values();
    }

    function trustedPortCount() public view returns (uint256) {
        return _trustedPorts.length();
    }

    function isTrustedPort(address port) public view returns (bool) {
        return _trustedPorts.contains(port);
    }

    function setToPort(uint256 toChainId, address toPortAddress) external onlyOwner {
        _setToPort(toChainId, toPortAddress);
    }

    function setFromPort(uint256 fromChainId, address fromPortAddress) external onlyOwner {
        _setFromPort(fromChainId, fromPortAddress);
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        RemoteCallArgs memory args = abi.decode(params, (RemoteCallArgs));

        uint256 len = args.ports.length;
        require(toChainId != LOCAL_CHAINID(), "!toChainId");
        require(len == args.params.length, "!len");
        require(len == args.fees.length, "!len");
        if (block.timestamp > args.expiration || block.timestamp + MAX_MESSAGE_EXPIRATION < args.expiration) {
            revert("!expiration");
        }

        PortMsg memory portMsg = PortMsg({
            fromChainId: LOCAL_CHAINID(),
            toChainId: toChainId,
            fromDapp: fromDapp,
            toDapp: toDapp,
            nonce: args.nonce,
            expiration: args.expiration,
            message: message
        });
        bytes memory encoded = abi.encodeWithSelector(MultiPort.multiRecv.selector, portMsg);
        bytes32 portMsgId = hash(portMsg);

        bool[] memory sentResult = _multiSend(args, toChainId, encoded);
        emit PortMessageSent(portMsgId, portMsg, sentResult);
    }

    function _multiSend(RemoteCallArgs memory args, uint256 toChainId, bytes memory encoded)
        internal
        returns (bool[] memory)
    {
        uint256 len = args.ports.length;
        uint256 totalFee = 0;
        bool[] memory sentResult = new bool[](len);
        for (uint256 i = 0; i < len; i++) {
            uint256 fee = args.fees[i];
            address port = args.ports[i];
            require(isTrustedPort(port), "!trusted");
            sentResult[i] = _sendMessage(port, fee, toChainId, encoded, args.params[i]);
            totalFee += fee;
        }

        require(totalFee == msg.value, "!fees");
        return sentResult;
    }

    function _sendMessage(address port, uint256 fee, uint256 toChainId, bytes memory encoded, bytes memory params)
        internal
        returns (bool r)
    {
        try IMessagePort(port).send{value: fee}(toChainId, _checkedToPort(toChainId), encoded, params) {
            r = true;
        } catch {
            r = false;
        }
    }

    function multiRecv(PortMsg calldata portMsg) external payable {
        address port = _msgPort();
        require(isTrustedPort(port), "!trusted");
        uint256 fromChainId = _fromChainId();
        require(LOCAL_CHAINID() == portMsg.toChainId, "!toChainId");
        require(fromChainId == portMsg.fromChainId, "!fromChainId");
        require(fromChainId != LOCAL_CHAINID(), "!fromChainId");
        require(_xmsgSender() == _checkedFromPort(fromChainId), "!xmsgSender");
        bytes32 portMsgId = hash(portMsg);
        require(deliverifyOf[portMsgId][port] == false, "deliveried");
        deliverifyOf[portMsgId][port] = true;
        ++countOf[portMsgId];

        emit PortMessageConfirmation(portMsgId, port);

        if (block.timestamp > portMsg.expiration || block.timestamp + MAX_MESSAGE_EXPIRATION < portMsg.expiration) {
            emit PortMessageExpired(portMsgId);
            return;
        }

        require(doneOf[portMsgId] == false, "done");
        if (countOf[portMsgId] >= threshold) {
            doneOf[portMsgId] = true;
            _recv(portMsg.fromChainId, portMsg.fromDapp, portMsg.toDapp, portMsg.message);
            emit PortMessageExecution(portMsgId);
        }
    }

    function hash(PortMsg memory portMsg) public pure returns (bytes32) {
        return keccak256(abi.encode(portMsg));
    }
}
