// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LineRegistry is Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    // remoteChainId => localLineAddress[]
    mapping(uint64 => EnumerableSet.AddressSet) private _localLineLookup;

    function LOCAL_CHAINID() public view returns (uint64) {
        return uint64(block.chainid);
    }

    function getLocalLinesByToChainId(uint64 toChainId_) external view returns (address[] memory) {
        return _localLineLookup[toChainId_].values();
    }

    function getLocalLinesLengthByToChainId(uint64 toChainId_) external view returns (uint256) {
        return _localLineLookup[toChainId_].length();
    }

    function getLocalLineByToChainIdAndIndex(uint64 toChainId_, uint256 index_) external view returns (address) {
        return _localLineLookup[toChainId_].at(index_);
    }

    function addLocalLine(uint64 remoteChainId_, address localLine_) external onlyOwner {
        require(_localLineLookup[remoteChainId_].add(localLine_), "!add");
    }

    function localLineExists(uint64 remoteChainId_, address localLine_) public view returns (bool) {
        return _localLineLookup[remoteChainId_].contains(localLine_);
    }
}
