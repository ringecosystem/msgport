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

    string c3;
    string config;
    address PORT;

    function name() public pure override returns (string memory) {
        return "PortConfig";
    }

    function setUp() public override {
        super.setUp();
        c3 = ScriptTools.readInput("../c3");
        string memory key = string(abi.encodePacked(".", vm.envOr("PORT_KEY", string(""))));
        PORT = c3.readAddress(key);
    }

    function run(uint256[] memory chainIds, string memory uri) public {
        setPort(chainIds);
        setURI(uri);
    }

    function setPort(uint256[] memory chainIds) public broadcast {
        for (uint256 i = 0; i < chainIds.length; i++) {
            uint256 chainId = chainIds[i];
            III(PORT).setFromPort(chainId, PORT);
            require(III(PORT).fromPortLookup(chainId) == PORT);
            III(PORT).setToPort(chainId, PORT);
            require(III(PORT).toPortLookup(chainId) == PORT);
        }
    }

    function setURI(string memory uri) public broadcast {
        III(PORT).setURI(uri);
        require(eq(III(PORT).uri(), uri));
    }

    function eq(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
