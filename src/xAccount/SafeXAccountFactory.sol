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
import "../interfaces/ISafeProxyFactory.sol";
import "../interfaces/IModuleFactory.sol";
import "../interfaces/ISafe.sol";
import "../interfaces/IPortRegistry.sol";
import "../interfaces/IMessagePort.sol";
import "../ports/base/PortMetadata.sol";
import "../user/Application.sol";
import "../utils/CREATE3.sol";

/// @title SafeXAccountFactory
/// @dev SafeXAccountFactory is a factory contract for create xAccount.
///   - 1 account only have 1 xAccount on target chain for each factory.
contract SafeXAccountFactory is Ownable2Step, Application, PortMetadata {
    address public safeFallbackHandler;
    address public safeSingleton;
    ISafeProxyFactory public safeFactory;
    IModuleFactory public moduleFactory;

    IPortRegistry public immutable REGISTRY;

    address internal constant DEAD_OWNER = 0xDDdDddDdDdddDDddDDddDDDDdDdDDdDDdDDDDDDd;

    event SafeXAccountCreated(uint256 fromChainId, address deployer, address xAccount, address module, address port);

    constructor(
        address dao,
        address mfactory,
        address sfactory,
        address singleton,
        address fallbackHandler,
        address registry,
        string memory name
    ) PortMetadata(name) {
        _transferOwnership(dao);
        safeSingleton = singleton;
        safeFallbackHandler = fallbackHandler;
        safeFactory = ISafeProxyFactory(sfactory);
        moduleFactory = IModuleFactory(mfactory);
        REGISTRY = IPortRegistry(registry);
    }

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function setSafeFactory(address factory) external onlyOwner {
        safeFactory = ISafeProxyFactory(factory);
    }

    function setSafeSingleton(address singleton) external onlyOwner {
        safeSingleton = singleton;
    }

    function setSafeFallbackHandler(address fallbackHandler) external onlyOwner {
        safeFallbackHandler = fallbackHandler;
    }

    function setModuleFactory(address factory) external onlyOwner {
        moduleFactory = IModuleFactory(factory);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function isRegistred(address port) public view returns (bool) {
        return REGISTRY.get(LOCAL_CHAINID(), port) != bytes4(0);
    }

    function _toFactory(uint256 toChainId) internal view returns (address l) {
        l = REGISTRY.get(toChainId, code());
        require(l != address(0), "!to");
    }

    function _fromFactory(uint256 fromChainId) internal view returns (address) {
        return REGISTRY.get(fromChainId, code());
    }

    /// @dev Cross chian function for create xAccount on target chain.
    /// @notice If recovery address is `address(0)`, do not enabale recovery module.
    /// @param code Port code that used for create xAccount.
    /// @param toChainId Target chain id.
    /// @param params Port params correspond with the port.
    /// @param recovery The default safe recovery module address on target chain for xAccount.
    function xCreate(bytes4 code, uint256 toChainId, bytes calldata params, address recovery) external payable {
        uint256 fee = msg.value;
        require(toChainId != LOCAL_CHAINID(), "!toChainId");

        address deployer = msg.sender;
        bytes memory encoded = abi.encodeWithSelector(SafeXAccountFactory.xDeploy.selector, deployer, recovery);
        address port = REGISTRY.get(LOCAL_CHAINID(), code);
        IMessagePort(port).send{value: fee}(toChainId, _toFactory(toChainId), encoded, params);
    }

    /// @dev Create xAccount on target chain.
    /// @notice Only could be called by source chain.
    /// @param deployer Deployer on source chain.
    /// @param recovery The default safe recovery module address for xAccount.
    /// @return Deployed xAccount address.
    function xDeploy(address deployer, address recovery) external returns (address, address) {
        address port = _msgPort();
        uint256 fromChainId = _fromChainId();
        require(isRegistred(port), "!port");
        require(_xmsgSender() == _fromFactory(fromChainId), "!xmsgSender");

        return _deploy(fromChainId, deployer, port, recovery);
    }

    function _deploy(uint256 chainId, address deployer, address port, address recovery)
        internal
        returns (address proxy, address module)
    {
        require(chainId != LOCAL_CHAINID(), "!chainId");

        bytes32 salt = keccak256(abi.encodePacked(chainId, deployer));
        (proxy, module) = _deploySafeXAccount(salt, chainId, deployer, port);
        _setUp(proxy, module, recovery);

        emit SafeXAccountCreated(chainId, deployer, proxy, module, port);
    }

    function setupModules(address module, address recovery) external {
        ISafe safe = ISafe(address(this));
        safe.enableModule(module);
        if (recovery != address(0)) safe.enableModule(recovery);
    }

    function _setUp(address proxy, address module, address recovery) internal {
        bytes memory setupModulesData =
            abi.encodeWithSelector(SafeXAccountFactory.setupModules.selector, module, recovery);
        uint256 threshold = 1;
        address[] memory owners = new address[](1);
        owners[0] = DEAD_OWNER;
        ISafe(proxy).setup(
            owners,
            threshold,
            address(this),
            setupModulesData,
            safeFallbackHandler,
            address(0x0),
            0,
            payable(address(0x0))
        );
    }

    function _deploySafeXAccount(bytes32 salt, uint256 chainId, address owner, address port)
        internal
        returns (address proxy, address module)
    {
        (proxy, module) = CREATE3.getDeployed(salt, address(this));
        bytes memory creationCode1 = safeFactory.proxyCreationCode();
        bytes memory deploymentCode1 = abi.encodePacked(creationCode1, uint256(uint160(safeSingleton)));

        bytes memory creationCode2 = moduleFactory.moduleCreationCode();
        bytes memory deploymentCode2 = abi.encodePacked(
            creationCode2, uint256(uint160(proxy)), chainId, uint256(uint160(owner)), uint256(uint160(port))
        );
        (proxy, module) = CREATE3.deploy(salt, deploymentCode1, deploymentCode2);
    }

    /// @dev Calculate xAccount address on target chain.
    /// @notice The module address is only effective during its creation and may be replaced by the xAccount in the future.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param toChainId Chain id that xAccount lives in.
    /// @param deployer Owner that xAccount belongs to.
    /// @return (xAccount address, module address).
    function safeXAccountOf(uint256 fromChainId, uint256 toChainId, address deployer)
        public
        view
        returns (address, address)
    {
        return safeXAccountOf(fromChainId, deployer, _toFactory(toChainId));
    }

    /// @dev Calculate xAccount address.
    /// @notice The module address is only effective during its creation and may be replaced by the xAccount in the future.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param deployer Owner that xAccount belongs to.
    /// @param factory Factory that create xAccount.
    /// @return (xAccount address, module address).
    function safeXAccountOf(uint256 fromChainId, address deployer, address factory)
        public
        pure
        returns (address, address)
    {
        bytes32 salt = keccak256(abi.encodePacked(fromChainId, deployer));
        return CREATE3.getDeployed(salt, factory);
    }
}
