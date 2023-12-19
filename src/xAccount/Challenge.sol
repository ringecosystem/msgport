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

interface ITimeLock {
    function grantRole(bytes32 role, address account) external;
    function schedule(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt,
        uint256 delay
    ) external;
    function hashOperation(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt)
        external
        pure
        returns (bytes32);
}

contract Challenge {
    address public immutable CHALLENGER;
    uint256 public immutable CHALLENGE_PERIOD;
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    event StartChallenge(address timelock, bytes32 id);

    constructor(address challenger, uint256 period) {
        CHALLENGER = challenger;
        CHALLENGE_PERIOD = period;
    }

    function startChallenge(address timelock) external payable returns (bytes32 id) {
        require(CHALLENGER == msg.sender, "!auth");
        uint256 value = msg.value;
        bytes memory data = abi.encodeWithSelector(ITimeLock.grantRole.selector, PROPOSER_ROLE, CHALLENGER);
        if (value > 0) {
            (bool success,) = timelock.call{value: value}("");
            require(success, "!transfer");
        }
        ITimeLock(timelock).schedule(timelock, value, data, bytes32(0), bytes32(0), CHALLENGE_PERIOD);
        id = ITimeLock(timelock).hashOperation(timelock, value, data, bytes32(0), bytes32(0));
        emit StartChallenge(timelock, id);
    }
}
