// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessageLine.sol";
import "./LineMetadata.sol";

abstract contract BaseMessageLine is IMessageLine, LineMetadata {
    constructor(string memory name) LineMetadata(name) {}

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        virtual;

    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params) public payable {
        _send(msg.sender, toChainId, toDapp, message, params);
    }

    function _recv(uint256 fromChainId, address fromDapp, address toDapp, bytes memory message)
        internal
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) =
            toDapp.call{value: msg.value}(abi.encodePacked(message, fromChainId, fromDapp));
        if (success) {
            return returndata;
        } else {
            revert MessageFailure(returndata);
        }
    }

    function fee(uint256, address, bytes calldata, bytes calldata) external view virtual returns (uint256) {
        revert("Unimplemented!");
    }
}
