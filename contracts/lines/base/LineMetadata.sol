// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/ILineMetadata.sol";

contract LineMetadata is ILineMetadata {
    struct Metadata {
        string name;
        string provider;
        string description;
    }

    Metadata public metadata;

    constructor(Metadata memory metadata_) {
        metadata = metadata_;
    }

    function name() public view returns (string memory) {
        return metadata.name;
    }
}
