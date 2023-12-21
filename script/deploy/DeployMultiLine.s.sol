// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import "../../src/lines/MultiLine.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployMultiLine is Common {
    using stdJson for string;
    using ScriptTools for string;

    address REGISTRY;
    address ADDR;
    bytes32 SALT;

    string c3;
    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;

    function name() public pure override returns (string memory) {
        return "DeployMultiLine";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy_multi_line.c"));
        outputName = "deploy_multi_line.a";
        config = ScriptTools.readInput(instanceId);
        c3 = ScriptTools.readInput("../c3");
        REGISTRY = c3.readAddress(".LINEREGISTRY_ADDR");
        ADDR = c3.readAddress(".MULTILINE_ADDR");
        SALT = c3.readBytes32(".MULTILINE_SALT");

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();
        // setConfig();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "MULTI_LINE", ADDR);
    }

    function deploy() public broadcast returns (address) {
        string memory name_ = config.readString(".metadata.name");
        bytes memory byteCode = type(MultiLine).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, REGISTRY, name_));
        address line = _deploy3(SALT, initCode);
        require(line == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        console.log("MultiLine deployed: %s", line);
        return line;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
