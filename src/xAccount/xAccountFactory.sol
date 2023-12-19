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
import "../interfaces/ILineRegistry.sol";
import "../interfaces/IMessageLine.sol";
import "../interfaces/IxAccount.sol";
import "../lines/base/LineLookup.sol";
import "../user/Application.sol";
import "./xAccountProxy.sol";

contract xAccountFactory is Ownable2Step, Application, LineLookup {
    address public xAccountLogic;

    ILineRegistry public immutable REGISTRY;

    event xAccountCreated(uint256 fromChainId, address deployer, address xAccount);
    event NewXAccountLogic(address logic);

    constructor(address dao, address registry, address logic) {
        _transferOwnership(dao);
        REGISTRY = ILineRegistry(registry);
        xAccountLogic = logic;
    }

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function setLogic(address logic) external onlyOwner {
        xAccountLogic = logic;
        emit NewXAccountLogic(logic);
    }

    function setToLine(uint256 _toChainId, address _toLineAddress) external onlyOwner {
        _setToLine(_toChainId, _toLineAddress);
    }

    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external onlyOwner {
        _setFromLine(_fromChainId, _fromLineAddress);
    }

    function _toLine(uint256 toChainId) internal view returns (address) {
        return toLineLookup[toChainId];
    }

    function _fromLine(uint256 fromChainId) internal view returns (address) {
        return fromLineLookup[fromChainId];
    }

    function xCreate(string calldata name, uint256 toChainId, bytes calldata params) external payable {
        address line = REGISTRY.getLine(name);
        uint256 fee = msg.value;
        require(line != address(0), "!name");
        require(toChainId != LOCAL_CHAINID(), "!toChainId");

        address deployer = msg.sender;
        bytes memory encoded = abi.encodeWithSelector(xAccountFactory.xDeploy.selector, deployer);
        IMessageLine(line).send{value: fee}(toChainId, _toLine(toChainId), encoded, params);
    }

    function xDeploy(address deployer) external payable {
        address line = _msgLine();
        uint256 fromChainId = _fromChainId();
        require(REGISTRY.isTrustedLine(line), "!line");
        require(_xmsgSender() == _fromLine(fromChainId), "!xmsgSender");
        require(fromChainId != LOCAL_CHAINID(), "!fromChainId");

        address proxy = _create2(fromChainId, deployer);
        emit xAccountCreated(fromChainId, deployer, proxy);
    }

    function _create2(uint256 chainId, address deployer) internal returns (address proxy) {
        bytes memory initCode = abi.encodePacked(type(xAccountProxy).creationCode, chainId, uint256(uint160(deployer)));

        assembly {
            proxy := create2(callvalue(), add(initCode, 32), mload(initCode), 0)
        }
        IxAccount(proxy).initialize(xAccountLogic);
    }

    function xAccountOf(uint256 toChainId, address deployer) external view returns (address) {
        address factory = _toLine(toChainId);
        require(toChainId != LOCAL_CHAINID(), "!toChainId");
        require(factory != address(0), "!factory");
        return xAccountOf(LOCAL_CHAINID(), deployer, factory);
    }

    function xAccountOf(uint256 fromChainId, address deployer, address factory) external pure returns (address) {
        bytes memory initCode =
            abi.encodePacked(type(xAccountProxy).creationCode, fromChainId, uint256(uint160(deployer)));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff", factory, bytes32(0), keccak256(initCode))))));
    }
}
