// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPortMetadata {
    event URI(string uri);

    /// @notice Get the port name, it's globally unique and immutable.
    /// @return The MessagePort name.
    function name() external view returns (string memory);

    /// @return The port metadata uri.
    function uri() external view returns (string memory);
}
