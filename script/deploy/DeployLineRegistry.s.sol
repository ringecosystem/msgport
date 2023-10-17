// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

import "../../contracts/LineRegistry.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployLineRegistry is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ADDR = 0x003BE514Ee7cdec49A7d664D39C38274DD4841A6;
    bytes32 immutable SALT = 0x1cbc695b2f17fb4c0268bec3185314174b93b9f9f4731a2c8578257a3602d48f;

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

        instanceId = vm.envOr("INSTANCE_ID", string("deploy.c"));
        outputName = "deploy.a";
        config = ScriptTools.readInput(instanceId);

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "LINE_REGISTRY", ADDR);
    }

    function deploy() public broadcast returns (address) {
        bytes memory byteCode = type(LineRegistry).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address registry = _deploy(SALT, initCode);
        require(registry == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        setConfig(ADDR);
        console.log("LineRegistry deployed: %s", ADDR);
        return ADDR;
    }

    function setConfig(address addr) public {
        III(addr).transferOwnership(dao);
        require(III(addr).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
