// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessageLine.sol";
import "./LineMetadata.sol";
import "./LineLookup.sol";

abstract contract BaseMessageLine is IMessageLine, LineMetadata {
    uint256 public nonce;

    constructor(Metadata memory metadata) LineMetadata(metadata) {}

    function LOCAL_CHAINID() public view returns (uint64) {
        return uint64(block.chainid);
    }

    function _incrementNonce() internal returns (uint256) {
        nonce = nonce + 1;
        return nonce;
    }

    function _hash(uint64 fromChainId, uint256 nonce_) internal view returns (bytes32) {
        return keccak256(abi.encode(fromChainId, nonce_, address(this)));
    }

    function _send(address fromDapp, uint64 toChainId, address toDapp, bytes memory messagePayload, bytes memory params)
        internal
        virtual;

    function send(uint64 toChainId, address toDapp, bytes memory payload, bytes memory params) public payable virtual {
        uint256 nonce_ = _incrementNonce();
        uint64 fromChainId = LOCAL_CHAINID();
        bytes32 messageId = _hash(fromChainId, nonce_);
        bytes memory messagePayloadWithId = abi.encode(messageId, payload);

        _send(msg.sender, toChainId, toDapp, messagePayloadWithId, params);

        emit MessageSent(
            messageId, fromChainId, toChainId, msg.sender, toDapp, messagePayloadWithId, params, address(this)
        );
    }

    function _recv(uint64 fromChainId, address fromDapp, address toDapp, bytes memory message) internal {
        (bytes32 messageId, bytes memory messagePayload) = abi.decode(message, (bytes32, bytes));

        (bool success, bytes memory returndata) =
            toDapp.call(abi.encodePacked(messagePayload, messageId, uint256(fromChainId), fromDapp));

        if (success) {
            emit MessageReceived(messageId, address(this));
        } else {
            emit ReceiverError(messageId, returndata, address(this));
        }
    }

    function estimateFee(
        uint64, // Dest line chainId
        bytes calldata,
        bytes calldata
    ) external view virtual returns (uint256) {
        revert("Unimplemented!");
    }
}
