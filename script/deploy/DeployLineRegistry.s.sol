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

    address immutable ADDR = 0x00b986eA47A20d5E07617670381d3B8074fB82F8;
    bytes32 immutable SALT = 0xb4b0498c349c4b677b5d163def80005fa9695d5fb811af620a527809e5f7d7f7;

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
