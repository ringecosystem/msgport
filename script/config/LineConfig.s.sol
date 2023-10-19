// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {stdJson} from "forge-std/StdJson.sol";
import {Script} from "forge-std/Script.sol";
import "ORMP/script/Common.s.sol";

interface III {
    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external;
    function setToLine(uint256 _toChainId, address _toLineAddress) external;
}

contract LineConfig is Common {
    using stdJson for string;
    using ScriptTools for string;

    string config;
    address dao;
    address line;

    function name() public pure override returns (string memory) {
        return "RegistryLine";
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

    function run(uint256[] memory chainIds) public {
        require(dao == msg.sender, "!dao");
        setLine(chainIds);
    }

    function setLine(uint256[] memory chainIds) public broadcast {
        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            string memory key = string.concat(".", vm.toString(chainId));
            address l = config.readAddress(key);
            III(line).setFromLine(chainId, l);
            III(line).setToLine(chainId, l);
        }
    }
}
