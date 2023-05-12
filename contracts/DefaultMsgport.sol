// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./interfaces/IMsgport.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/MessageDock.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DefaultMsgport is IMsgport, Ownable2Step {
    uint public immutable localChainId;

    // target chain id => dock address
    // ref: https://github.com/ethereum-lists/chains
    mapping(uint => address) public dockAddresses;

    event DockUpdated(
        uint localChainId,
        address oldDockAddress,
        address newDockAddress
    );

    constructor(uint _localChainId) {
        localChainId = _localChainId;
    }

    /// Add dock address for a target chain.
    /// TODO: support multiple dock addresses for a target chain.
    ///
    /// @param _chainId Target chain id.
    /// @param _dockAddress Dock address.
    function addDock(uint _chainId, address _dockAddress) external onlyOwner {
        require(_chainId != localChainId, "!localChainId");
        require(_dockAddress != dockAddresses[_chainId], "!dockAddress");

        address oldDockAddress = dockAddresses[_chainId];
        dockAddresses[_chainId] = _dockAddress;
        emit DockUpdated(_chainId, oldDockAddress, _dockAddress);
    }

    function getLocalChainId() external view override returns (uint) {
        return localChainId;
    }

    // called by Dapp.
    function send(
        uint _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        uint256 _fee,
        bytes memory _params
    ) external payable returns (uint256) {
        require(_toChainId != localChainId, "!localChainId");

        address dockAddress = dockAddresses[_toChainId];
        require(dockAddress != address(0), "!dockAddress");

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= _fee, "!fee");

        // refund fee to caller if paid too much.
        if (paid > _fee) {
            payable(msg.sender).transfer(paid - _fee);
        }

        return
            MessageDock(dockAddress).send{value: _fee}(
                msg.sender,
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
        uint _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external {
        address dockAddress = dockAddresses[_fromChainId];
        require(msg.sender == dockAddress, "!dock");

        try
            IMessageReceiver(_toDappAddress).recv(
                _fromDappAddress,
                _messagePayload
            )
        {} catch Error(string memory reason) {
            emit DappError(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                reason
            );
        } catch (bytes memory reason) {
            emit DappError(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                string(reason)
            );
        }
    }
}
