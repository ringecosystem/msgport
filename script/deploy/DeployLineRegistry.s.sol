// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

import "../../src/LineRegistry.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployLineRegistry is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ADDR = 0x0057460B22649fF60d987139687BF6cc46F164B2;
    bytes32 immutable SALT = 0x5a7432902b0c0f6a904d402f7d56f72c97abd054a22d90ff896e3fce69aa37b5;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;

    function name() public pure override returns (string memory) {
        return "Deploy";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy_line_registry.c"));
        outputName = "deploy_line_registry.a";
        config = ScriptTools.readInput(instanceId);

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();
        setConfig();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "LINE_REGISTRY", ADDR);
    }

    function deploy() public broadcast returns (address) {
        bytes memory byteCode = type(LineRegistry).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address registry = _deploy(SALT, initCode);
        require(registry == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        console.log("LineRegistry deployed: %s", ADDR);
        return ADDR;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
