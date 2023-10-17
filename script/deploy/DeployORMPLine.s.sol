// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

import "../../contracts/lines/ORMPLine.sol";

interface III {
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function pendingOwner() external view returns (address);
}

contract DeployORMPLine is Common {
    using stdJson for string;
    using ScriptTools for string;

    address immutable ORMP = 0x0000000000BD9dcFDa5C60697039E2b3B28b079b;
    address immutable ADDR = 0x0008131d835B64AEd43402B2b4819dD33A61B22f;
    bytes32 immutable SALT = 0x86871dbe09a9d5bcc1568fec103f7edb02a27999acb76eeb665ff8fcc9d6d195;

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
        ScriptTools.exportContract(outputName, "ORMP_LINE", ADDR);
    }

    function deploy() public broadcast returns (address) {
        string memory name_ = "ORMP line by msgport";
        bytes memory byteCode = type(ORMPLine).creationCode;
        bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, ORMP, name_));
        address line = _deploy(SALT, initCode);
        require(line == ADDR, "!addr");
        require(III(ADDR).owner() == deployer);
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
