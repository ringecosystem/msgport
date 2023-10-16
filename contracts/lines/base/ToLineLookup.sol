// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ToLineLookup {
    event SetToLine(uint256 toChainId, address toLine);

    // toChainId => toLineAddress
    mapping(uint256 => address) public toLineLookup;

    function _setToLine(uint256 toChainId, address toLine) internal virtual {
        toLineLookup[toChainId] = toLine;
        emit SetToLine(toChainId, toLine);
    }
}
