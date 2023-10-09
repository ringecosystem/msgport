// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessageLine.sol";

abstract contract BaseMessageLine is IMessageLine {
    struct Metadata {
        string name;
        string provider;
        string description;
    }

    uint256 public nonce;

    // toChainId => toLineAddress
    mapping(uint64 => address) public toLineLookup;
    // fromChainId => fromLineAddress
    mapping(uint64 => address) public fromLineLookup;

    address public immutable lowLevelMessager;

    Metadata public metadata;

    constructor(address _lowLevelMessager, Metadata memory _metadata) {
        metadata = _metadata;
        lowLevelMessager = _lowLevelMessager;
    }

    function name() public view returns (string memory) {
        return metadata.name;
    }

    function LOCAL_CHAINID() public view returns (uint64) {
        return uint64(block.chainid);
    }

    function toLineExists(uint64 _toChainId) public view virtual returns (bool) {
        return toLineLookup[_toChainId] != address(0);
    }

    function _addToLine(uint64 _toChainId, address _toLine) internal virtual {
        require(toLineExists(_toChainId) == false, "Line: ToLine already exists");
        toLineLookup[_toChainId] = _toLine;
    }

    function fromLineExists(uint64 _fromChainId) public view virtual returns (bool) {
        return fromLineLookup[_fromChainId] != address(0);
    }

    function _addFromLine(uint64 _fromChainId, address _fromLine) internal virtual {
        require(fromLineExists(_fromChainId) == false, "Line: FromLine already exists");
        fromLineLookup[_fromChainId] = _fromLine;
    }

    function _incrementNonce() internal returns (uint256) {
        nonce = nonce + 1;
        return nonce;
    }

    function _hash(uint64 _chainid, uint256 _nonce) internal view returns (bytes32) {
        return keccak256(abi.encode(_chainid, _nonce, address(this)));
    }

    function _send(
        address _fromDapp,
        uint64 _toChainId,
        address _toDapp,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual;

    function send(uint64 _toChainId, address _toDapp, bytes memory _payload, bytes memory _params)
        public
        payable
        virtual
    {
        uint256 _nonce = _incrementNonce();
        bytes32 messageId = _hash(LOCAL_CHAINID(), _nonce);
        bytes memory messagePayloadWithId = abi.encode(messageId, _payload);

        _send(msg.sender, _toChainId, _toDapp, messagePayloadWithId, _params);

        emit MessageSent(
            messageId, LOCAL_CHAINID(), _toChainId, msg.sender, _toDapp, messagePayloadWithId, _params, address(this)
        );
    }

    function _recv(uint64 _fromChainId, address _fromDapp, address _toDapp, bytes memory _message) internal {
        (bytes32 messageId, bytes memory messagePayload_) = abi.decode(_message, (bytes32, bytes));

        (bool success, bytes memory returndata) =
            _toDapp.call(abi.encodePacked(messagePayload_, messageId, uint256(_fromChainId), _fromDapp));

        if (success) {
            emit MessageReceived(messageId, msg.sender);
        } else {
            emit ReceiverError(messageId, string(returndata), msg.sender);
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
