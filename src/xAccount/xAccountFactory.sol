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
import "../lines/base/LineMetadata.sol";
import "../user/Application.sol";
import "./xAccountProxy.sol";

/// @title xAccountFactory
/// @dev xAccountFactory is a factory contract for create xAccount.
///   - 1 account only have 1 xAccount on target chain for each factory.
contract xAccountFactory is Ownable2Step, Application, LineMetadata {
    /// @dev xAccount logic contract.
    address public xAccountLogic;

    ILineRegistry public immutable REGISTRY;

    event xAccountCreated(uint256 fromChainId, address deployer, address xAccount);
    event NewXAccountLogic(address logic);

    constructor(address dao, address logic, address registry, string memory name) LineMetadata(name) {
        _transferOwnership(dao);
        xAccountLogic = logic;
        REGISTRY = ILineRegistry(registry);
    }

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function setLogic(address logic) external onlyOwner {
        xAccountLogic = logic;
        emit NewXAccountLogic(logic);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function isRegistred(address line) public view returns (bool) {
        return REGISTRY.get(LOCAL_CHAINID(), line) != bytes4(0);
    }

    function _toFactory(uint256 toChainId) internal view returns (address l) {
        l = REGISTRY.get(toChainId, code());
        require(l != address(0), "!to");
    }

    function _fromFactory(uint256 fromChainId) internal view returns (address) {
        return REGISTRY.get(fromChainId, code());
    }

    /// @dev Cross chian function for create xAccount on target chain.
    /// @param code Line code that used for create xAccount.
    /// @param toChainId Target chain id.
    /// @param params Line params correspond with the line.
    function xCreate(bytes4 code, uint256 toChainId, bytes calldata params) external payable {
        uint256 fee = msg.value;
        require(toChainId != LOCAL_CHAINID(), "!toChainId");

        address deployer = msg.sender;
        bytes memory encoded = abi.encodeWithSelector(xAccountFactory.xDeploy.selector, deployer);
        address line = REGISTRY.get(LOCAL_CHAINID(), code);
        IMessageLine(line).send{value: fee}(toChainId, _toFactory(toChainId), encoded, params);
    }

    /// @dev Create xAccount on target chain.
    /// @notice Only could be called by source chain.
    /// @param deployer Deployer on source chain.
    /// @return Deployed xAccount address.
    function xDeploy(address deployer) external returns (address) {
        address line = _msgLine();
        uint256 fromChainId = _fromChainId();
        require(isRegistred(line), "!line");
        require(_xmsgSender() == _fromFactory(fromChainId), "!xmsgSender");

        return _deploy(fromChainId, deployer, line);
    }

    function _deploy(uint256 chainId, address deployer, address line) internal returns (address proxy) {
        require(chainId != LOCAL_CHAINID(), "!chainId");

        bytes memory initCode = type(xAccountProxy).creationCode;
        bytes32 salt = keccak256(abi.encode(chainId, deployer));

        assembly {
            proxy := create2(0, add(initCode, 32), mload(initCode), salt)
        }
        IxAccount(proxy).initialize(xAccountLogic, chainId, deployer, line);

        emit xAccountCreated(chainId, deployer, proxy);
    }

    /// @dev Calculate xAccount address on target chain.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param toChainId Chain id that xAccount lives in.
    /// @param deployer Owner that xAccount belongs to.
    /// @return xAccount address.
    function xAccountOf(uint256 fromChainId, uint256 toChainId, address deployer) public view returns (address) {
        return xAccountOf(fromChainId, deployer, _toFactory(toChainId));
    }

    /// @dev Calculate xAccount address.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param deployer Owner that xAccount belongs to.
    /// @param factory Factory that create xAccount.
    /// @return xAccount address.
    function xAccountOf(uint256 fromChainId, address deployer, address factory) public pure returns (address) {
        bytes memory initCode =
            abi.encodePacked(type(xAccountProxy).creationCode, fromChainId, uint256(uint160(deployer)));
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff", factory, bytes32(0), keccak256(initCode))))));
    }
}
