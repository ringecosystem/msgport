// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract FromLineLookup {
    event SetFromLine(uint256 fromChainId, address fromLine);

    // fromChainId => fromLineAddress
    mapping(uint256 => address) public fromLineLookup;

    function _setFromLine(uint256 fromChainId, address fromLine) internal virtual {
        fromLineLookup[fromChainId] = fromLine;
        emit SetFromLine(fromChainId, fromLine);
    }
}
