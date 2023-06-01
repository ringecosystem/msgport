// This file is part of Darwinia.
// Copyright (C) 2018-2022 Darwinia Network
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

pragma solidity >=0.8.9;

interface IMsgport {
    event DappError(
        uint64 _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes _message,
        string _reason
    );

    function getLocalChainId() external view returns (uint64);

    function send(
        address _throughLocalDock,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) external payable returns (uint256);

    function recv(
        uint64 _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _message
    ) external;
}
