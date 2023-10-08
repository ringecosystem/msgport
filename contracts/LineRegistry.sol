// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./interfaces/ILineRegistry.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract LineRegistry is ILineRegistry, Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint128 private _nonce;

    // remoteChainId => localLineAddress[]
    mapping(uint64 => EnumerableSet.AddressSet) private _localLineAddressLookup;

    receive() external payable {}

    function getLocalChainId() public view returns (uint64) {
        return uint64(block.chainid);
    }

    function getLocalLineAddressesByToChainId(uint64 toChainId_) external view returns (address[] memory) {
        return _localLineAddressLookup[toChainId_].values();
    }

    function getLocalLineAddressesLengthByToChainId(uint64 toChainId_) external view returns (uint256) {
        return _localLineAddressLookup[toChainId_].length();
    }

    function getLocalLineAddressByToChainIdAndIndex(uint64 toChainId_, uint256 index_)
        external
        view
        returns (address)
    {
        return _localLineAddressLookup[toChainId_].at(index_);
    }

    function addLocalLine(uint64 remoteChainId_, address localLineAddress_) external onlyOwner {
        require(_localLineAddressLookup[remoteChainId_].add(localLineAddress_), "!add");
    }

    function localLineExists(uint64 remoteChainId_, address localLineAddress_) public view returns (bool) {
        return _localLineAddressLookup[remoteChainId_].contains(localLineAddress_);
    }

    function nextMessageId(uint64 toChainId_) public returns (uint256) {
        require(localLineExists(toChainId_, msg.sender), "Invalid message line address.");
        _nonce++;
        uint256 messageId = (uint256(getLocalChainId()) << 128) + uint256(_nonce);
        return messageId;
    }
}
