// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import "ORMP/src/ORMP.sol";
import "ORMP/src/interfaces/IORMP.sol";
import "ORMP/src/UserConfig.sol";

import "../../src/lines/ORMPLine.sol";
import "../../src/lines/base/FromLineLookup.sol";

contract ORMPLineTest is Test {
    using Chains for uint256;

    ORMPLine ormpLine;
    address dao;
    address ormpProtocol;

    function setUp() public {
        uint256 chainId = Chains.Crab;
        vm.createSelectFork(chainId.toChainName());
        dao = address(0x1);
        ormpProtocol = address(0x00000000001523057a05d6293C1e5171eE33eE0A);
        ormpLine = new ORMPLine(dao, vm.envOr("ORMP_ADDRESS", address(ormpProtocol)), "ORMP");
    }

    function testSetUri() public {
        string memory testUri = "https://test.uri";
        vm.prank(dao);
        ormpLine.setURI(testUri);
        assertEq(ormpLine.uri(), testUri);
        // Cannot
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(address(0));
        ormpLine.setURI("https://test.uri");
    }

    function testSetAppConfig() public {
        vm.prank(dao);
        ormpLine.setAppConfig(address(0x2), address(0x3));
        UC memory uc = IORMP(vm.envOr("ORMP_ADDRESS", address(ormpProtocol))).getAppConfig(address(ormpLine));
        assertEq(uc.oracle, address(0x2));
        assertEq(uc.relayer, address(0x3));
        // Cannot
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(address(0));
        ormpLine.setAppConfig(address(0x2), address(0x3));
    }

    function testSetLine() public {
        // From line
        vm.prank(dao);
        ormpLine.setFromLine(1, address(0x1));
        vm.prank(dao);
        ormpLine.setFromLine(2, address(0x2));
        assertEq(LineLookup(ormpLine).fromLineLookup(1), address(0x1));
        assertEq(LineLookup(ormpLine).fromLineLookup(2), address(0x2));
        // To line
        vm.prank(dao);
        ormpLine.setToLine(3, address(0x3));
        vm.prank(dao);
        ormpLine.setToLine(4, address(0x4));
        assertEq(LineLookup(ormpLine).toLineLookup(3), address(0x3));
        assertEq(LineLookup(ormpLine).toLineLookup(4), address(0x4));
        // Cannot
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        ormpLine.setFromLine(5, address(0x5));
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        ormpLine.setFromLine(6, address(0x6));
    }

    function testSend() public {
        uint256 toChainId = 421614;
        address toDapp = address(0x1837ff30801F1793563451101350A5f5e14a0a1a);
        address refund = address(0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85);
        bytes memory message = bytes(
            "0xd8e68172000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000"
        );
        bytes memory params = bytes("0x");
        bytes memory adapterParams = abi.encode(500000, refund, params);
        uint256 fee = ormpLine.fee(toChainId, toDapp, message, adapterParams);
        ormpLine.send{value: fee}(toChainId, toDapp, message, adapterParams);
    }
}
