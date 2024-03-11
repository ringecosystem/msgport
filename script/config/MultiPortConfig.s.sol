// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function addTrustedPort(address port) external;
    function isTrustedPort(address port) external view returns (bool);
}

contract MultiPortConfig is Common {
    using stdJson for string;
    using ScriptTools for string;

    string c3;
    string config;
    address MULTI_PORT;
    address ORMP_PORT;

    function name() public pure override returns (string memory) {
        return "MultiPortConfig";
    }

    function setUp() public override {
        super.setUp();
        c3 = ScriptTools.readInput("../c3");
        MULTI_PORT = c3.readAddress(".MULTIPORT_ADDR");
        ORMP_PORT = c3.readAddress(".ORMPPORT_ADDR");
    }

    function run() public {
        addORMPPort();
    }

    function addORMPPort() public broadcast {
        III(MULTI_PORT).addTrustedPort(ORMP_PORT);
        require(III(MULTI_PORT).isTrustedPort(ORMP_PORT), "!add");
    }
}
