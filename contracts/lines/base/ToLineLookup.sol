// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ToLineLookup {
    // toChainId => toLineAddress
    mapping(uint256 => address) public toLineLookup;

    function toLineExists(uint256 toChainId) public view virtual returns (bool) {
        return toLineLookup[toChainId] != address(0);
    }

    function _addToLine(uint256 toChainId, address toLine) internal virtual {
        require(toLineExists(toChainId) == false, "Line: ToLine already exists");
        toLineLookup[toChainId] = toLine;
    }
}
