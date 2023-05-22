// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./interfaces/IMsgport.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/BaseMessageDock.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DefaultMsgport is IMsgport, Ownable2Step {
    uint256 public localChainId;

    // remoteChainId => localDockAddress[]
    mapping(uint256 => address[]) public localDockAddressesByToChainId;

    constructor(uint256 _localChainId) {
        localChainId = _localChainId;
    }

    function getLocalChainId() external view returns (uint256) {
        return localChainId;
    }

    function addLocalDock(
        uint256 _remoteChainId,
        address _localDockAddress
    ) external onlyOwner {
        require(
            !localDockExists(_remoteChainId, _localDockAddress),
            "Dock already exists"
        );

        localDockAddressesByToChainId[_remoteChainId].push(_localDockAddress);
    }

    function localDockExists(
        uint256 _remoteChainId,
        address _localDockAddress
    ) public view returns (bool) {
        address[] memory localDockAddresses = localDockAddressesByToChainId[
            _remoteChainId
        ];
        bool exists = false;
        for (uint i = 0; i < localDockAddresses.length; i++) {
            if (localDockAddresses[i] == _localDockAddress) {
                exists = true;
                break;
            }
        }
        return exists;
    }

    // called by Dapp.
    function send(
        address _throughLocalDockAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        bytes memory _params
    ) external payable returns (uint256) {
        // check if local dock exists
        require(
            localDockExists(_toChainId, _throughLocalDockAddress),
            "Local dock not exists"
        );

        return
            BaseMessageDock(_throughLocalDockAddress).send{value: msg.value}(
                msg.sender, // fromDappAddress
                _toChainId,
                _toDappAddress,
                _messagePayload,
                _params
            );
    }

    // called by dock.
    //
    // catch the error if user's recv function failed with uncaught error.
    // store the message and error for the user to do something like retry.
    function recv(
        uint256 _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external {
        require(
            localDockExists(_fromChainId, msg.sender),
            "Local dock not exists"
        );

        try
            IMessageReceiver(_toDappAddress).recv(
                _fromChainId,
                _fromDappAddress,
                _messagePayload
            )
        {} catch Error(string memory reason) {
            emit DappError(
                _fromChainId,
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                reason
            );
        } catch (bytes memory reason) {
            emit DappError(
                _fromChainId,
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                string(reason)
            );
        }
    }
}
