// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0 <0.9.0;

import "./GNSPSBytesLib.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library Utils {
    // ruby: "dacb".unpack('H*') => 0x64616362
    //
    // input: 0x64616362
    // return: 1684104034
    function bytesToUint64(
        bytes memory input
    ) internal pure returns (uint64 output) {
        require(input.length >= 8, "input must be at least 8 bytes");
        bytes memory inputWithLeftPadding = input;
        for (uint i = 0; i < 8 - input.length; i++) {
            inputWithLeftPadding = GNSPSBytesLib.concat(
                hex"00",
                inputWithLeftPadding
            );
        }
        output = GNSPSBytesLib.toUint64(inputWithLeftPadding, 0);
    }

    // input: 1684104034
    // return: 0x0000000064616362
    function uint64ToBytes(
        uint64 input
    ) internal pure returns (bytes memory output) {
        output = abi.encodePacked(input);
    }

    function bytesToUint16(
        bytes memory input
    ) internal pure returns (uint16 output) {
        require(input.length >= 2, "input must be at least 2 bytes");
        bytes memory inputWithLeftPadding = input;
        for (uint i = 0; i < 2 - input.length; i++) {
            inputWithLeftPadding = GNSPSBytesLib.concat(
                hex"00",
                inputWithLeftPadding
            );
        }
        output = GNSPSBytesLib.toUint16(inputWithLeftPadding, 0);
    }

    function uint16ToBytes(
        uint16 input
    ) internal pure returns (bytes memory output) {
        output = abi.encodePacked(input);
    }

    function removeLeadingZero(
        bytes memory data
    ) internal pure returns (bytes memory) {
        uint length = data.length;

        uint startIndex = 0;
        for (uint i = 0; i < length; i++) {
            if (data[i] != 0) {
                startIndex = i;
                break;
            }
        }

        return GNSPSBytesLib.slice(data, startIndex, length - startIndex);
    }

    function bytesToAddress(
        bytes memory addressBytes
    ) internal pure returns (address) {
        return address(bytes20(bytes(addressBytes)));
    }

    function hexStringToAddress(
        string memory addressString
    ) internal pure returns (address) {
        return address(bytes20(bytes(addressString)));
    }

    function addressToHexString(
        address addr
    ) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(addr)), 20);
    }

    function revertWithMessage(
        bytes memory returndata,
        string memory errorMessage
    ) internal pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
