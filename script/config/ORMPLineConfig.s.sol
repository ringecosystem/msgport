// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

interface III {
    function addLine(address line) external;
    function getLine(string calldata name) external view returns (address);
    function name() external view returns (string memory);
}

contract ORMP is Common {
    using stdJson for string;
    using ScriptTools for string;

    address dao;
    address registry;

    function name() public pure override returns (string memory) {
        return "RegistryLine";
    }

    function setUp() public override {
        super.setUp();
        string memory deployedLineRegistry = ScriptTools.readOutput("deploy_line_registry.a");
        dao = deployedLineRegistry.readAddress(".DAO");
        registry = deployedLineRegistry.readAddress(".LINE_REGISTRY");
    }

    function run() public {
        require(dao == msg.sender, "!dao");
        string memory file = vm.envOr("LINE_FILE", string(""));
        string memory key = vm.envOr("LINE_KEY", string(""));
        address line = ScriptTools.readOutput(file).readAddress(key);
        addLine(line);
    }

    function addLine(address line) public broadcast {
        III(registry).addLine(line);
        string memory name_ = III(line).name();
        require(III(registry).getLine(name_) == line);
    }
}
