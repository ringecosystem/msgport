// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./interfaces/ILineMetadata.sol";

contract LineRegistry is Ownable2Step {
    // lineName => lineAddress
    mapping(string => address) private _lineLookup;

    function getLine(string calldata name) external view returns (address) {
        return _lineLookup[name];
    }

    function addLine(address line) external onlyOwner {
        string memory name = ILineMetadata(line).name();
        require(_lineLookup[name] == address(0), "Line name already exists");
        _lineLookup[name] = line;
    }
}
