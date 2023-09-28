// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/IMessageLine.sol";
import "../../interfaces/ILineRegistry.sol";

abstract contract BaseMessageLine is IMessageLine {
    struct Metadata {
        string name;
        string provider;
        string description;
        string offChainFeeApi;
    }

    // toChainId => toLineAddress
    mapping(uint64 => address) public toLineAddressLookup;
    // fromChainId => fromLineAddress
    mapping(uint64 => address) public fromLineAddressLookup;

    address public immutable localMessagingContractAddress;
    ILineRegistry public immutable LINE_REGISTRY;

    Metadata public metadata;

    constructor(
        address _localLineRegistry,
        address _localMessagingContractAddress,
        Metadata memory _metadata
    ) {
        metadata = _metadata;
        LINE_REGISTRY = ILineRegistry(_localLineRegistry);
        localMessagingContractAddress = _localMessagingContractAddress;
    }

    function _updateFeeApi(string memory _feeApi) internal virtual {
        metadata.offChainFeeApi = _feeApi;
    }

    function getLocalChainId() public view returns (uint64) {
        return LINE_REGISTRY.getLocalChainId();
    }

    function toLineExists(
        uint64 _toChainId
    ) public view virtual returns (bool) {
        return toLineAddressLookup[_toChainId] != address(0);
    }

    function _addToLine(
        uint64 _toChainId,
        address _toLineAddress
    ) internal virtual {
        require(
            toLineExists(_toChainId) == false,
            "Line: ToLine already exists"
        );
        toLineAddressLookup[_toChainId] = _toLineAddress;
    }

    function fromLineExists(
        uint64 _fromChainId
    ) public view virtual returns (bool) {
        return fromLineAddressLookup[_fromChainId] != address(0);
    }

    function _addFromLine(
        uint64 _fromChainId,
        address _fromLineAddress
    ) internal virtual {
        require(
            fromLineExists(_fromChainId) == false,
            "Line: FromLine already exists"
        );
        fromLineAddressLookup[_fromChainId] = _fromLineAddress;
    }

    function _send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) internal virtual;

    function send(
        address _fromDappAddress,
        uint64 _toChainId,
        address _toDappAddress,
        bytes memory _payload,
        bytes memory _params
    ) public payable virtual {
        uint256 messageId = LINE_REGISTRY.nextMessageId(_toChainId);
        bytes memory messagePayloadWithId = abi.encode(messageId, _payload);

        _send(
            _fromDappAddress,
            _toChainId,
            _toDappAddress,
            messagePayloadWithId,
            _params
        );

        emit MessageSent(
            messageId,
            LINE_REGISTRY.getLocalChainId(),
            _toChainId,
            msg.sender,
            _toDappAddress,
            messagePayloadWithId,
            _params,
            address(this)
        );
    }

    function _recv(
        uint64 _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _message
    ) internal {
        (uint256 messageId, bytes memory messagePayload_) = abi.decode(
            _message,
            (uint256, bytes)
        );

        (bool success, bytes memory returndata) = _toDappAddress.call(
            abi.encodePacked(
                messagePayload_,
                messageId,
                uint256(_fromChainId),
                _fromDappAddress,
                msg.sender
            )
        );

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
