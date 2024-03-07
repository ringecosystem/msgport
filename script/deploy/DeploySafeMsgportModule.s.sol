// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

import "../../src/xAccount/SafeMsgportModule.sol";

contract DeploySafeMsgportModule is Common {
    using stdJson for string;
    using ScriptTools for string;

    address ADDR;
    bytes32 SALT;

    string c3;
    string outputName;
    address deployer;

    function name() public pure override returns (string memory) {
        return "DeploySafeMsgportModule";
    }

    function setUp() public override {
        super.setUp();

        outputName = "deploy_safe_msgport_module.a";
        c3 = ScriptTools.readInput("../c3");
        ADDR = c3.readAddress(".SAFEMSGPORTMODULE_ADDR");
        SALT = c3.readBytes32(".SAFEMSGPORTMODULE_SALT");
        deployer = c3.readAddress(".DEPLOYER");
    }

    function run() public {
        require(deployer == msg.sender, "!deployer");

        deploy();

        ScriptTools.exportContract(outputName, "DEPLOYER", deployer);
        ScriptTools.exportContract(outputName, "SAFE_MSGPORT_MODULE", ADDR);
    }

    function deploy() public broadcast returns (address) {
        bytes memory byteCode = type(SafeMsgportModule).creationCode;
        address module = _deploy3(SALT, byteCode);
        require(module == ADDR, "!addr");
        console.log("SafeMsgportModule deployed: %s", module);
        return module;
    }
}
