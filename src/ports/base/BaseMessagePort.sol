// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/IMessagePort.sol";
import "./PortMetadata.sol";

abstract contract BaseMessagePort is IMessagePort, PortMetadata {
    modifier checkToDapp(address) virtual {
        _;
    }

    constructor(string memory name) PortMetadata(name) {}

    function LOCAL_CHAINID() public view returns (uint256) {
        return block.chainid;
    }

    /// @dev Send a cross-chain message over the MessagePort.
    ///      Port developer should implement this, then it will be called by `send`.
    /// @param fromDapp The real sender account who send the message.
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    /// @return msgId Return the ID of message.
    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        virtual
        returns (bytes32 msgId);

    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        payable
        returns (bytes32 msgId)
    {
        msgId = _send(msg.sender, toChainId, toDapp, message, params);
        emit MessageSent(msgId, msg.sender, toChainId, toDapp, message, params);
    }

    /// @dev Make toDapp accept messages.
    ///      This should be called by message port when a message is received.
    /// @param msgId The ID of message.
    /// @param fromChainId The source chainId, standard evm chainId.
    /// @param fromDapp The message sender in source chain.
    /// @param toDapp The message receiver in dest chain.
    /// @param message The message body.
    function _recv(bytes32 msgId, uint256 fromChainId, address fromDapp, address toDapp, bytes memory message)
        internal
        checkToDapp(toDapp)
    {
        (bool success, bytes memory returndata) =
            toDapp.call{value: msg.value}(abi.encodePacked(message, msgId, fromChainId, fromDapp));
        emit MessageRecv(msgId, success, returndata);
    }

    function fee(uint256, address, address, bytes calldata, bytes calldata) external view virtual returns (uint256) {
        revert("Unimplemented!");
    }
}
