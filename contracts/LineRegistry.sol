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

    function getLocalLinesByToChainId(uint64 toChainId) external view returns (address[] memory) {
        return _localLineLookup[toChainId].values();
    }

    function getLocalLinesLengthByToChainId(uint64 toChainId) external view returns (uint256) {
        return _localLineLookup[toChainId].length();
    }

    function getLocalLineByToChainIdAndIndex(uint64 toChainId, uint256 index) external view returns (address) {
        return _localLineLookup[toChainId].at(index);
    }

    function addLocalLine(uint64 remoteChainId, address localLine) external onlyOwner {
        require(_localLineLookup[remoteChainId].add(localLine), "!add");
    }

    function localLineExists(uint64 remoteChainId, address localLine) public view returns (bool) {
        return _localLineLookup[remoteChainId].contains(localLine);
    }
}
