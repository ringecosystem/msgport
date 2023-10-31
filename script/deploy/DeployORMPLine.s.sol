// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import "../../src/lines/ORMPLine.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployORMPLine is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x009D223Aad560e72282db9c0438Ef1ef2bf7703D;
    address immutable ADDR = 0x001ddFd752a071964fe15C2386ec1811963D00C2;
    bytes32 immutable SALT = 0xee434b1ec4dc63ddd14cc0199092bd3ea9b6315bcf21e06e1579ce107d5bd492;

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
        address line = _deploy3(SALT, initCode);
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
