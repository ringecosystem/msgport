// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function setFromPort(uint256 fromChainId, address fromPortAddress) external;
    function setToPort(uint256 toChainId, address toPortAddress) external;
    function fromPortLookup(uint256) external view returns (address);
    function toPortLookup(uint256) external view returns (address);
    function setURI(string calldata uri) external;
    function uri() external view returns (string memory);
}

contract PortConfig is Common {
    using stdJson for string;
    using ScriptTools for string;

    string config;
    address dao;
    address port;

    function name() public pure override returns (string memory) {
        return "PortConfig";
    }

    function setUp() public override {
        super.setUp();
        string memory configFile = vm.envOr("PORT_CONFIG_FILE", string(""));
        config = ScriptTools.readInput(configFile);
        string memory file = vm.envOr("PORT_DEPLOY_FILE", string(""));
        string memory key = vm.envOr("PORT_KEY", string(""));
        string memory deployedPort = ScriptTools.readOutput(file);
        port = deployedPort.readAddress(key);
        dao = deployedPort.readAddress(".DAO");
    }

    function run(uint256[] memory chainIds, string memory uri) public {
        require(dao == msg.sender, "!dao");
        setPort(chainIds);
        // setURI(uri);
    }

    function setPort(uint256[] memory chainIds) public broadcast {
        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            string memory key = string.concat(".", vm.toString(chainId));
            address l = config.readAddress(key);
            III(port).setFromPort(chainId, l);
            require(III(port).fromPortLookup(chainId) == l);
            III(port).setToPort(chainId, l);
            require(III(port).toPortLookup(chainId) == l);
        }
    }

    function setURI(string memory uri) public broadcast {
        III(port).setURI(uri);
        require(eq(III(port).uri(), uri));
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
