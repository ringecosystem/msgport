// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import "../../src/xAccount/XAccountFactory.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployXAccountFactory is Common {
    using stdJson for string;
    using ScriptTools for string;

    address ADDR;
    bytes32 SALT;
    address MODULE;
    address REGISTRY;

    string c3;
    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;

    function name() public pure override returns (string memory) {
        return "DeployXAccountFactory";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy_xaccount_factory.c"));
        outputName = "deploy_xaccount_factory.a";
        config = ScriptTools.readInput(instanceId);
        c3 = ScriptTools.readInput("../c3");
        ADDR = c3.readAddress(".XACCOUNTFACTORY_ADDR");
        SALT = c3.readBytes32(".XACCOUNTFACTORY_SALT");
        MODULE = c3.readAddress(".SAFEMSGPORTMODULE_ADDR");
        REGISTRY = c3.readAddress(".PORTREGISTRY_ADDR");

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
    }

    function readSafeDeployment()
        internal
        returns (address proxyFactory, address gnosisSafe, address fallbackHandler)
    {
        uint256 chainId = vm.envOr("CHAIN_ID", block.chainid);
        string memory root = vm.projectRoot();
        string memory safeFolder = string(abi.encodePacked("/lib/safe-deployments/src/assets/", safeVerison, "/"));
        string memory proxyFactoryFile = vm.readFile(string(abi.encodePacked(root, safeFolder, "proxy_factory.json")));
        proxyFactory =
            proxyFactoryFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
        string memory gasisSafeJson;
        if (chainId.isL2()) {
            gasisSafeJson = "gnosis_safe_l2.json";
        } else {
            gasisSafeJson = "gnosis_safe.json";
        }

        string memory fallbackHandlerFile =
            vm.readFile(string(abi.encodePacked(root, safeFolder, "compatibility_fallback_handler.json")));
        fallbackHandler =
            fallbackHandleFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));

        string memory gnosisSageFile = vm.readFile(string(abi.encodePacked(root, safeFolder, gasisSafeJson)));
        gnosisSafe = gnosisSageFile.readAddress(string(abi.encodePacked(".networkAddresses.", vm.toString(chainId))));
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();
        // setConfig();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "XACCOUNT_FACTORY", ADDR);
    }

    function deploy() public broadcast returns (address) {
        string memory name_ = config.readString(".metadata.name");
        (address safeFactory, address safeSingleton, address safeFallbackHandler) = readSafeDeployment();
        bytes memory byteCode = type(ORMPPort).creationCode;
        bytes memory initCode = bytes.concat(
            byteCode, abi.encode(deployer, MODULE, safeFactory, safeSingleton, safeFallbackHandler, REGISTRY, nema_)
        );
        address port = _deploy3(SALT, initCode);
        require(port == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        console.log("ORMPPort deployed: %s", port);
        return port;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
