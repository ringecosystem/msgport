// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
//
// import {stdJson} from "forge-std/StdJson.sol";
// import {Script} from "forge-std/Script.sol";
// import {console2 as console} from "forge-std/console2.sol";
// import {Common} from "create3-deploy/script/Common.s.sol";
// import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";
//
// import "../../src/xAccount/xAccountFactory.sol";
//
// interface III {
//     function owner() external view returns (address);
// }
//
// contract DeployXAccountFactory is Common {
//     using stdJson for string;
//     using ScriptTools for string;
//
//     address REGISTRY;
//     address LOGIC;
//     address ADDR;
//     bytes32 SALT;
//
//     string c3;
//     string config;
//     string instanceId;
//     string outputName;
//     address deployer;
//
//     function name() public pure override returns (string memory) {
//         return "DeployXAccountFactory";
//     }
//
//     function setUp() public override {
//         super.setUp();
//
//         instanceId = vm.envOr("INSTANCE_ID", string("deploy_xaccount_factory.c"));
//         outputName = "deploy_xaccount_factory.a";
//         config = ScriptTools.readInput(instanceId);
//         c3 = ScriptTools.readInput("../c3");
//         REGISTRY = c3.readAddress(".LINEREGISTRY_ADDR");
//         LOGIC = c3.readAddress(".XACCOUNT_ADDR");
//         ADDR = c3.readAddress(".XACCOUNTFACTORY_ADDR");
//         SALT = c3.readBytes32(".XACCOUNTFACTORY_SALT");
//
//         deployer = config.readAddress(".DEPLOYER");
//     }
//
//     function run() public {
//         require(deployer == msg.sender, "!deployer");
//
//         deploy();
//
//         ScriptTools.exportContract(outputName, "XACCOUNT_FACTORY", ADDR);
//     }
//
//     function deploy() public broadcast returns (address) {
//         bytes memory byteCode = type(xAccountFactory).creationCode;
//         bytes memory initCode = bytes.concat(byteCode, abi.encode(deployer, REGISTRY, LOGIC));
//         address x = _deploy3(SALT, initCode);
//         require(x == ADDR, "!addr");
//         require(III(ADDR).owner() == deployer);
//         console.log("xAccountFactory deployed: %s", x);
//         return x;
//     }
// }
