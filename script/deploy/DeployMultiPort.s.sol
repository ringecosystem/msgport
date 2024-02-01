// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import "../../src/ports/MultiPort.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployMultiPort is Common {
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

    function name() public pure override returns (string memory) {
        return "DeployMultiPort";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy_multi_port.c"));
        outputName = "deploy_multi_port.a";
        config = ScriptTools.readInput(instanceId);
        c3 = ScriptTools.readInput("../c3");
        REGISTRY = c3.readAddress(".PORTREGISTRY_ADDR");
        ADDR = c3.readAddress(".MULTIPORT_ADDR");
        SALT = c3.readBytes32(".MULTIPORT_SALT");

        deployer = config.readAddress(".DEPLOYER");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();

        ScriptTools.exportContract(outputName, "MULTI_port", ADDR);
    }

    function deploy() public broadcast returns (address) {
        string memory name_ = config.readString(".metadata.name");
        bytes memory byteCode = type(MultiPort).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, REGISTRY, name_));
        address port = _deploy3(SALT, initCode);
        require(port == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        console.log("MultiPort deployed: %s", port);
        return port;
    }
}
