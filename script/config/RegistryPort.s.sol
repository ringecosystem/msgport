// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function set(uint256 chainId, string calldata name, address port) external;
    function get(uint256 chainId, string calldata name) external view returns (address);
    function name() external view returns (string memory);
}

contract RegistryPort is Common {
    using stdJson for string;
    using ScriptTools for string;

    string c3;
    uint256 CHAIN_ID;
    address REGISTRY;
    address PORT;

    function name() public pure override returns (string memory) {
        return "RegistryPort";
    }

    function setUp() public override {
        super.setUp();
        c3 = ScriptTools.readInput("../c3");
        REGISTRY = c3.readAddress(".PORTREGISTRY_ADDR");
        string memory key = string(abi.encodePacked(".", vm.envOr("PORT_KEY", string(""))));
        PORT = c3.readAddress(key);
        CHAIN_ID = vm.envOr("CHAIN_ID", block.chainid);
    }

    function run(uint256[] memory chainIds, string calldata name_) public {
        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            addPort(chainId, name_);
        }
    }

    function addPort(uint256 chainId, string memory name_) public broadcast {
        III(REGISTRY).set(chainId, name_, PORT);
        require(III(REGISTRY).get(chainId, name_) == PORT);
    }
}
