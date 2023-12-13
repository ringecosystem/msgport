// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import {Common} from "create3-deploy/script/Common.s.sol";
import {ScriptTools} from "create3-deploy/script/ScriptTools.sol";

interface III {
    function setFromLine(uint256 fromChainId, address fromLineAddress) external;
    function setToLine(uint256 toChainId, address toLineAddress) external;
    function fromLineLookup(uint256) external view returns (address);
    function toLineLookup(uint256) external view returns (address);
    function setURI(string calldata uri) external;
    function uri() external view returns (string memory);
}

contract LineConfig is Common {
    using stdJson for string;
    using ScriptTools for string;

    string config;
    address dao;
    address line;

    function name() public pure override returns (string memory) {
        return "LineConfig";
    }

    function setUp() public override {
        super.setUp();
        string memory configFile = vm.envOr("LINE_CONFIG_FILE", string(""));
        config = ScriptTools.readInput(configFile);
        string memory file = vm.envOr("LINE_DEPLOY_FILE", string(""));
        string memory key = vm.envOr("LINE_KEY", string(""));
        string memory deployedLine = ScriptTools.readOutput(file);
        line = deployedLine.readAddress(key);
        dao = deployedLine.readAddress(".DAO");
    }

    function run(uint256[] memory chainIds, string memory uri) public {
        require(dao == msg.sender, "!dao");
        // setLine(chainIds);
        // setURI(uri);
    }

    function setLine(uint256[] memory chainIds) public broadcast {
        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            string memory key = string.concat(".", vm.toString(chainId));
            address l = config.readAddress(key);
            III(line).setFromLine(chainId, l);
            require(III(line).fromLineLookup(chainId) == l);
            III(line).setToLine(chainId, l);
            require(III(line).toLineLookup(chainId) == l);
        }
    }

    function setURI(string memory uri) public broadcast {
        III(line).setURI(uri);
        require(eq(III(line).uri(), uri));
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
