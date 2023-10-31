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

import "./base/BaseMessageLine.sol";
import "./base/ToLineLookup.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

interface IMessageEndpoint {
    function remoteExecute(uint32 specVersion, address callReceiver, bytes calldata callPayload, uint256 gasLimit)
        external
        payable
        returns (uint256);

    function fee() external view returns (uint128);
}

contract DarwiniaS2sLine is BaseMessageLine, ToLineLookup, Ownable2Step {
    address public immutable lowLevelMessager;

    constructor(
        address _darwiniaEndpointAddress,
        uint256 _remoteChainId,
        address _remoteLineAddress,
        string memory _name
    ) BaseMessageLine(_name) {
        // add outbound and inbound lane
        _setToLine(_remoteChainId, _remoteLineAddress);
        lowLevelMessager = _darwiniaEndpointAddress;
    }

    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata _params
    ) internal override {
        (uint32 specVersion, uint256 gasLimit) = abi.decode(_params, (uint32, uint256));

        bytes memory recvCall = abi.encodeWithSignature(
            "recv(uint256,address,address,address,bytes)",
            LOCAL_CHAINID(),
            address(this),
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        IMessageEndpoint(lowLevelMessager).remoteExecute{value: msg.value}(
            specVersion, toLineLookup[_toChainId], recvCall, gasLimit
        );
    }
}
