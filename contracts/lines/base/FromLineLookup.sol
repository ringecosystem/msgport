// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract FromLineLookup {
    // fromChainId => fromLineAddress
    mapping(uint256 => address) public fromLineLookup;

    function fromLineExists(uint256 fromChainId) public view virtual returns (bool) {
        return fromLineLookup[fromChainId] != address(0);
    }

    function _addFromLine(uint256 fromChainId, address fromLine) internal virtual {
        require(fromLineExists(fromChainId) == false, "Line: FromLine already exists");
        fromLineLookup[fromChainId] = fromLine;
    }
}
