// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

import "../../src/lines/ORMPLine.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployORMPLine is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x0034607daf9c1dc6628f6e09E81bB232B6603A89;
    address immutable ADDR = 0x000C61ca18583C9504691f43Ea43C2c638772487;
    bytes32 immutable SALT = 0x1b2f099faec9acf3b39aab869e9c491491850d6f423917dacf1492f0c326a4c1;

    string config;
    string instanceId;
    string outputName;
    address deployer;
    address dao;

    function name() public pure override returns (string memory) {
        return "DeployORMPLine";
    }

    function setUp() public override {
        super.setUp();

        instanceId = vm.envOr("INSTANCE_ID", string("deploy_ormp_line.c"));
        outputName = "deploy_ormp_line.a";
        config = ScriptTools.readInput(instanceId);

        deployer = config.readAddress(".DEPLOYER");
        dao = config.readAddress(".DAO");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();
        setConfig();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "ORMP_LINE", ADDR);
    }

    function deploy() public broadcast returns (address) {
        string memory name_ = config.readString(".metadata.name");
        bytes memory byteCode = type(ORMPLine).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP, name_));
        address line = _deploy(SALT, initCode);
        require(line == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        console.log("ORMPLine deployed: %s", line);
        return line;
    }

    function setConfig() public broadcast {
        III(ADDR).transferOwnership(dao);
        require(III(ADDR).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
