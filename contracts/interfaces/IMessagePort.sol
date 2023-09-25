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

pragma solidity ^0.8.0;

interface IMessagePort {
    event MessageSent(
        uint256 indexed _messageId,
        uint64 _fromChainId,
        uint64 _toChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes _message,
        bytes _params,
        address _fromLineAddress
    );

    event MessageReceived(uint256 indexed _messageId, address _toLineAddress);

    event ReceiverError(
        uint256 indexed _messageId,
        string _reason,
        address _toLineAddress
    );

    function getLocalChainId() external view returns (uint64);
    
    function nextMessageId(uint256 toChainId_) external returns (uint256);

    function estimateFee(
        address _messageLineAddress,
        uint64 _toChainId,
        bytes calldata _payload,
        bytes calldata _params
    ) external view returns (uint256);
}
