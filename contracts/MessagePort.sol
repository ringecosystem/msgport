// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./interfaces/IMessagePort.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/IMessageLine.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract MessagePort is IMessagePort, Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint64 private _localChainId;
    uint128 private _nonce;

    // remoteChainId => localLineAddress[]
    mapping(uint64 => EnumerableSet.AddressSet) private _localLineAddressLookup;

    constructor(uint64 localChainId_) {
        _localChainId = localChainId_;
    }

    receive() external payable {}

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function getLocalChainId() external view returns (uint64) {
        return _localChainId;
    }

    function getLocalLineAddressesByToChainId(
        uint64 toChainId_
    ) external view returns (address[] memory) {
        return _localLineAddressLookup[toChainId_].values();
    }

    function getLocalLineAddressesLengthByToChainId(
        uint64 toChainId_
    ) external view returns (uint256) {
        return _localLineAddressLookup[toChainId_].length();
    }

    function getLocalLineAddressByToChainIdAndIndex(
        uint64 toChainId_,
        uint256 index_
    ) external view returns (address) {
        return _localLineAddressLookup[toChainId_].at(index_);
    }

    function addLocalLine(
        uint64 remoteChainId_,
        address localLineAddress_
    ) external onlyOwner {
        require(_localLineAddressLookup[remoteChainId_].add(localLineAddress_), "!add");
    }

    function localLineExists(
        uint64 remoteChainId_,
        address localLineAddress_
    ) public view returns (bool) {
        return _localLineAddressLookup[remoteChainId_].contains(localLineAddress_);
    }

    // called by Dapp.
    function send(
        address throughLocalLineAddress_,
        uint64 toChainId_,
        address toDappAddress_,
        bytes memory messagePayload_,
        bytes memory params_
    ) external payable {
        // check if local line exists
        require(
            localLineExists(toChainId_, throughLocalLineAddress_),
            "Port: Local line does not exist"
        );

        _nonce++;
        uint256 messageId = (uint256(_localChainId) << 128) + uint256(_nonce);
        bytes memory messagePayloadWithId = abi.encode(messageId, messagePayload_);

        IMessageLine(throughLocalLineAddress_).send{value: msg.value}(
            msg.sender, // fromDappAddress
            toChainId_,
            toDappAddress_,
            messagePayloadWithId,
            params_
        );
        emit MessageSent(
            messageId,
            _localChainId,
            toChainId_,
            msg.sender,
            toDappAddress_,
            messagePayload_,
            params_,
            throughLocalLineAddress_
        );
    }

    // called by line.
    //
    // catch the error if user's recv function failed with uncaught error.
    // store the message and error for the user to do something like retry.
    function recv(
        uint64 fromChainId_,
        address fromDappAddress_,
        address toDappAddress_,
        bytes memory messagePayloadWithId_
    ) external {
        require(
            localLineExists(fromChainId_, msg.sender),
            "Port: Local line does not exist"
        );

        (uint256 messageId, bytes memory messagePayload_) = abi.decode(
            messagePayloadWithId_,
            (uint256, bytes)
        );

        try
            IMessageReceiver(toDappAddress_).recv(
                fromChainId_,
                msg.sender,
                fromDappAddress_,
                messagePayload_
            ) {
        } catch Error(string memory reason) {
            emit ReceiverError(
                messageId,
                reason,
                msg.sender
            );
        } catch (bytes memory reason) {
            emit ReceiverError(
                messageId,
                string(reason),
                msg.sender
            );
        }
        
        emit MessageReceived(
            messageId,
            msg.sender
        );
    }

    function estimateFee(
        address _messageLineAddress,
        uint64 _toChainId,
        bytes calldata _payload,
        bytes calldata _params
    ) external view returns (uint256){
        return IMessageLine(_messageLineAddress).estimateFee(_toChainId, _payload, _params);
    }
}
