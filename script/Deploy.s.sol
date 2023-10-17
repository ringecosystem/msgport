// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

import "../contracts/LineRegistry.sol";
import "../contracts/lines/ORMPLine.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract Deploy is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x0000000000BD9dcFDa5C60697039E2b3B28b079b;
    address immutable ADDR = 0x00E89fd15F05854FcbF1408Da77bef78b6e206B7;
    bytes32 immutable SALT = 0xf358040b746b8c535ee0fb72a198c57845852999a0eb5d2fd6ada0a7a5c43b08;

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

        deployLineRegistry();
        address ormpLine = deployORMPLine();

        ScriptTools.exportContract(outputName, "DAO", dao);
        ScriptTools.exportContract(outputName, "LINE_REGISTRY", ADDR);
        ScriptTools.exportContract(outputName, "ORMP_LINE", ormpLine);
    }

    function deployLineRegistry() public broadcast returns (address) {
        bytes memory byteCode = type(LineRegistry).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer));
        address registry = _deploy(SALT, initCode);
        require(registry == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
        setConfig(ADDR);
        console.log("LineRegistry deployed: %s", ADDR);
        return ADDR;
    }

    function deployORMPLine() public broadcast returns (address) {
        string memory ormpName = "ORMP line by msgport";
        ORMPLine ormpLine = new ORMPLine(ORMP, ormpName);
        address line = address(ormpLine);
        setConfig(line);
        console.log("ORMPLine deployed: %s", line);
        return line;
    }

    function setConfig(address addr) public {
        III(addr).transferOwnership(dao);
        require(III(addr).pendingOwner() == dao, "!dao");
        // TODO:: dao.acceptOwnership()
    }
}
