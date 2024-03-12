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

import "./base/BaseMessagePort.sol";
import "./base/PortLookup.sol";
import "ORMP/src/interfaces/IORMP.sol";
import "ORMP/src/user/UpgradeableApplication.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ORMPPort is Ownable2Step, UpgradeableApplication, BaseMessagePort, PortLookup {
    constructor(address dao, address ormp, string memory name) UpgradeableApplication(ormp) BaseMessagePort(name) {
        _transferOwnership(dao);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function setToPort(uint256 _toChainId, address _toPortAddress) external onlyOwner {
        _setToPort(_toChainId, _toPortAddress);
    }

    function setFromPort(uint256 _fromChainId, address _fromPortAddress) external onlyOwner {
        _setFromPort(_fromChainId, _fromPortAddress);
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        (uint256 gasLimit, address refund, bytes memory ormpParams) = abi.decode(params, (uint256, address, bytes));
        bytes memory encoded = abi.encodeWithSelector(ORMPPort.recv.selector, fromDapp, toDapp, message);
        IORMP(sender).send{value: msg.value}(
            toChainId, _checkedToPort(toChainId), gasLimit, encoded, refund, ormpParams
        );
    }

    function recv(address fromDapp, address toDapp, bytes calldata message) external payable onlyORMP {
        uint256 fromChainId = _fromChainId();
        require(_xmsgSender() == _checkedFromPort(fromChainId), "!auth");
        _recv(fromChainId, fromDapp, toDapp, message);
    }

    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        override
        returns (uint256)
    {
        (uint256 gasLimit,, bytes memory ormpParams) = abi.decode(params, (uint256, address, bytes));
        bytes memory encoded = abi.encodeWithSelector(ORMPPort.recv.selector, msg.sender, toDapp, message);
        return IORMP(sender).fee(toChainId, address(this), gasLimit, encoded, ormpParams);
    }
}
