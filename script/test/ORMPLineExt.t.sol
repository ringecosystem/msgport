// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import "ORMP/src/ORMP.sol";
import "ORMP/src/interfaces/IORMP.sol";
import "ORMP/src/UserConfig.sol";

import "../../src/lines/ORMPLine.sol";
import "../../src/lines/base/FromLineLookup.sol";
import "./ORMPLine.t.sol";
import "../../src/lines/ORMPLineExt.sol";

contract ORMPLineExtTest is Test {
    using Chains for uint256;

    ORMPLineExt ormpLineExt;
    address dao;
    address ormpProtocol;

    function setUp() public {
        uint256 chainId = Chains.Darwinia;
        vm.createSelectFork(chainId.toChainName());
        dao = address(0x1);
        ormpProtocol = address(0x00000000001523057a05d6293C1e5171eE33eE0A);
        ormpLineExt = new ORMPLineExt(dao, vm.envOr("ORMP_ADDRESS", address(ormpProtocol)), "ORMPExt");
    }

    function testDones() public {
        uint256 toChainId = 42161;
        address toDapp = address(0x1837ff30801F1793563451101350A5f5e14a0a1a);
        address refund = address(0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85);
        bytes memory message = bytes(
            "0xd8e68172000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000021234000000000000000000000000000000000000000000000000000000000000"
        );
        bytes memory params = bytes("0x");
        bytes memory adapterParams = abi.encode(500000, refund, params);
        uint256 fee = ormpLineExt.fee(toChainId, toDapp, message, adapterParams);
        ormpLineExt.send{value: fee}(toChainId, toDapp, message, adapterParams);
        bytes32 msgHash = ormpLineExt.latestMsgHash();
        assertEq(msgHash != 0, true);
        bool status = ormpLineExt.dones(msgHash);
        assertEq(status, false);
    }
}
