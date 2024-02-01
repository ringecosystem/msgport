// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function addPort(address port) external;
    function getPort(string calldata name) external view returns (address);
    function name() external view returns (string memory);
}

contract RegistryPort is Common {
    using stdJson for string;
    using ScriptTools for string;

    address dao;
    address registry;

    function name() public pure override returns (string memory) {
        return "RegistryPort";
    }

    function setUp() public override {
        super.setUp();
        string memory deployedPortRegistry = ScriptTools.readOutput("deploy_port_registry.a");
        dao = deployedPortRegistry.readAddress(".DAO");
        registry = deployedPortRegistry.readAddress(".port_REGISTRY");
    }

    function run() public {
        require(dao == msg.sender, "!dao");
        string memory file = vm.envOr("PORT_DEPLOY_FILE", string(""));
        string memory key = vm.envOr("PORT_KEY", string(""));
        address port = ScriptTools.readOutput(file).readAddress(key);
        addPort(port);
    }

    function addPort(address port) public broadcast {
        III(registry).addPort(port);
        string memory name_ = III(port).name();
        require(III(registry).getPort(name_) == port);
    }
}
