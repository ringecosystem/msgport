// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/ILineMetadata.sol";

contract LineMetadata is ILineMetadata {
    string internal _name;
    string internal _uri;

    constructor(string memory name_) {
        _name = name_;
    }

    function _setURI(string memory uri_) internal virtual {
        _uri = uri_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function uri() public view virtual returns (string memory) {
        return _uri;
    }
}
