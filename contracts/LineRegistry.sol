// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LineRegistry is Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    // remoteChainId => localLineAddress[]
    mapping(uint256 => EnumerableSet.AddressSet) private _localLineLookup;

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function getLocalLinesByToChainId(uint256 toChainId) external view returns (address[] memory) {
        return _localLineLookup[toChainId].values();
    }

    function getLocalLinesLengthByToChainId(uint256 toChainId) external view returns (uint256) {
        return _localLineLookup[toChainId].length();
    }

    function getLocalLineByToChainIdAndIndex(uint256 toChainId, uint256 index) external view returns (address) {
        return _localLineLookup[toChainId].at(index);
    }

    function addLocalLine(uint256 remoteChainId, address localLine) external onlyOwner {
        require(_localLineLookup[remoteChainId].add(localLine), "!add");
    }

    function localLineExists(uint256 remoteChainId, address localLine) public view returns (bool) {
        return _localLineLookup[remoteChainId].contains(localLine);
    }
}
