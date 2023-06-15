// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./interfaces/IMessagePort.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/IMessageDock.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract MessagePort is IMessagePort, Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    uint64 private _localChainId;

    // remoteChainId => localDockAddress[]
    mapping(uint64 => EnumerableSet.AddressSet) private _localDockAddressesByToChainId;

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

    function getLocalDockAddressesByToChainId(
        uint64 toChainId_
    ) external view returns (address[] memory) {
        return _localDockAddressesByToChainId[toChainId_].values();
    }

    function getLocalDockAddressesLengthByToChainId(
        uint64 toChainId_
    ) external view returns (uint256) {
        return _localDockAddressesByToChainId[toChainId_].length();
    }

    function getLocalDockAddressByToChainIdAndIndex(
        uint64 toChainId_,
        uint256 index_
    ) external view returns (address) {
        return _localDockAddressesByToChainId[toChainId_].at(index_);
    }

    function addLocalDock(
        uint64 remoteChainId_,
        address localDockAddress_
    ) external onlyOwner {
        require(
            !localDockExists(remoteChainId_, localDockAddress_),
            "Dock already exists"
        );
        _localDockAddressesByToChainId[remoteChainId_].add(localDockAddress_);
    }

    function localDockExists(
        uint64 remoteChainId_,
        address localDockAddress_
    ) public view returns (bool) {
        return _localDockAddressesByToChainId[remoteChainId_].contains(localDockAddress_);
    }

    // called by Dapp.
    function send(
        address throughLocalDockAddress_,
        uint64 toChainId_,
        address toDappAddress_,
        bytes memory messagePayload_,
        bytes memory params_
    ) external payable {
        // check if local dock exists
        require(
            localDockExists(toChainId_, throughLocalDockAddress_),
            "Local dock not exists"
        );

        IMessageDock(throughLocalDockAddress_).send{value: msg.value}(
            msg.sender, // fromDappAddress
            toChainId_,
            toDappAddress_,
            messagePayload_,
            params_
        );
    }

    // called by dock.
    //
    // catch the error if user's recv function failed with uncaught error.
    // store the message and error for the user to do something like retry.
    function recv(
        uint64 fromChainId_,
        address fromDappAddress_,
        address toDappAddress_,
        bytes memory messagePayload_,
        // TO DISCUSS: dapp should deal with nonce?
        uint256 nonce_
    ) external {
        require(
            localDockExists(fromChainId_, msg.sender),
            "Local dock not exists"
        );

        try
            IMessageReceiver(toDappAddress_).recv(
                fromChainId_,
                fromDappAddress_,
                messagePayload_,
                nonce_
            ) {
        } catch Error(string memory reason) {
            emit DappError(
                fromChainId_,
                fromDappAddress_,
                toDappAddress_,
                messagePayload_,
                reason
            );
        } catch (bytes memory reason) {
            emit DappError(
                fromChainId_,
                fromDappAddress_,
                toDappAddress_,
                messagePayload_,
                string(reason)
            );
        }
    }
}
