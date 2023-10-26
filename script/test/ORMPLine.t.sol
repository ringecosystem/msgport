// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import "../../src/lines/ORMPLine.sol";
import "../../lib/ORMP/src/ORMP.sol";
import "../../lib/ORMP/src/interfaces/IORMP.sol";
import "../../lib/ORMP/src/UserConfig.sol";
import "../../src/lines/base/FromLineLookup.sol";

contract ORMPLineTest is Test {
    ORMPLine ormpLine;
    address dao;

    function setUp() public {
        dao = address(0x1);
        ormpLine = new ORMPLine(dao, vm.envOr("ORMP_ADDRESS", address(0)), "ORMP");
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
        Config memory config = IORMP(vm.envOr("ORMP_ADDRESS", address(0))).getAppConfig(address(ormpLine));
        assertEq(config.oracle, address(0x2));
        assertEq(config.relayer, address(0x3));
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
        uint256 chainId = 521614;
        address toDapp = address(0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85);
        bytes memory message = bytes("0x12345678");
        bytes memory params = bytes("0x00000000000000000000000000000000000000000000000000000000000493e0");
        uint256 fee = ormpLine.fee(chainId, toDapp, message, params);
        ormpLine.send{value: fee}(chainId, toDapp, message, params);
    }
}
