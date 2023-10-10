// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./lines/base/LineMetadata.sol";

contract LineRegistry is Ownable2Step {
    // lineName => localLineAddress
    mapping(string => address) private _localLineLookup;

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function getLocalLine(string memory name) external view returns (address) {
        return _localLineLookup[name];
    }

    function addLocalLine(address localLine) external onlyOwner {
        string memory name = LineMetadata(localLine).name();
        require(_localLineLookup[name] == address(0), "Line name already exists");
        _localLineLookup[name] = localLine;
    }
}
