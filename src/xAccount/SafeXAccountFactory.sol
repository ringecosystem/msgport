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

import "solmate/utils/CREATE3.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../interfaces/ISafeProxyFactory.sol";
import "../interfaces/ISafe.sol";
import "../interfaces/ILineRegistry.sol";
import "../interfaces/IMessageLine.sol";
import "../lines/base/LineMetadata.sol";
import "../user/Application.sol";
import "./SafeMsgportModule.sol";

/// @title SafeXAccountFactory
/// @dev SafeXAccountFactory is a factory contract for create xAccount.
///   - 1 account only have 1 xAccount on target chain for each factory.
contract SafeXAccountFactory is Ownable2Step, Application, LineMetadata {
    address public safeFallbackHandler;
    address public safeSingleton;

    ISafeProxyFactory public immutable SAFE_FACTORY;
    ILineRegistry public immutable REGISTRY;

    address internal constant DEAD_OWNER = 0xDDdDddDdDdddDDddDDddDDDDdDdDDdDDdDDDDDDd;

    event NewSafeSingleton(address singleton);
    event SafeXAccountCreated(uint256 fromChainId, address deployer, address xAccount, address module, address line);

    constructor(
        address dao,
        address factory,
        address singleton,
        address fallbackHandler,
        address registry,
        string memory name
    ) LineMetadata(name) {
        _transferOwnership(dao);
        safeSingleton = singleton;
        safeFallbackHandler = fallbackHandler;
        SAFE_FACTORY = ISafeProxyFactory(factory);
        REGISTRY = ILineRegistry(registry);
    }

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function setSingleton(address singleton) external onlyOwner {
        safeSingleton = singleton;
        emit NewSafeSingleton(singleton);
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

    function _deploy(uint256 chainId, address deployer, address line)
        internal
        returns (address proxy, address module)
    {
        require(chainId != LOCAL_CHAINID(), "!chainId");

        bytes32 salt = keccak256(abi.encodePacked(chainId, deployer));
        proxy = _deploySafeXAccount(salt);

        salt = keccak256(abi.encodePacked(proxy, salt));
        module = _deploySafeMsgportModule(salt, proxy, chainId, deployer, line);

        bytes memory initModule = abi.encodeWithSelector(ISafe.enableModule.selector, module);
        address[] memory owners = new address[](1);
        owners[0] = DEAD_OWNER;
        ISafe(proxy).setup(owners, 1, safeSingleton, initModule, safeFallbackHandler, address(0x0), 0, address(0x0));

        emit SafeXAccountCreated(chainId, deployer, proxy, module, line);
    }

    function _deploySafeXAccount(bytes32 salt) internal returns (address proxy) {
        bytes memory creationCode = SAFE_FACTORY.proxyCreationCode();
        bytes memory deploymentCode = abi.encodePacked(creationCode, uint256(uint160(SAFE_SINGLETON)));
        proxy = CREATE3.deploy(salt, deploymentCode, 0);
    }

    function _deploySafeMsgportModule(bytes32 salt, address xAccount, uint256 chainId, address owner, address line)
        internal
        returns (address module)
    {
        bytes memory creationCode = type(SafeMsgportModule).creationCode;
        bytes memory deploymentCode = abi.encodePacked(
            creationCode, uint256(uint160(xAccount)), chainId, uint256(uint160(owner)), uint256(uint160(line))
        );
        module = CREATE3.deploy(salt, deploymentCode, 0);
    }

    /// @dev Calculate xAccount address on target chain.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param toChainId Chain id that xAccount lives in.
    /// @param deployer Owner that xAccount belongs to.
    /// @return (xAccount address, module address).
    function safeXAccountOf(uint256 fromChainId, uint256 toChainId, address deployer)
        public
        view
        returns (address, address)
    {
        return xAccountOf(fromChainId, deployer, _toFactory(toChainId));
    }

    /// @dev Calculate xAccount address.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param deployer Owner that xAccount belongs to.
    /// @param factory Factory that create xAccount.
    /// @return xAccount address.
    function safeXAccountOf(uint256 fromChainId, address deployer, address factory)
        public
        pure
        returns (address, address)
    {
        // TODO:: fix create3 only could fetch address(this) deployed contract address.
        bytes32 salt = keccak256(abi.encodePacked(chainId, deployer));
        address xAccount = CREATE3.getDeployed(salt);
        salt = keccak256(abi.encodePacked(xAccount, salt));
        address module = CREATE3.getDeployed(salt);
        return (xAccount, module);
    }
}
