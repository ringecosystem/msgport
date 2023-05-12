// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./interfaces/IMsgport.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/MessageDockBase.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DefaultMsgport is IMsgport, Ownable2Step {
    address public dockAddress;

    function setDock(address _dockAddress) external onlyOwner {
        dockAddress = _dockAddress;
    }

    // called by Dapp.
    function send(
        address _toDappAddress,
        bytes memory _messagePayload,
        uint256 _fee,
        bytes memory _params
    ) external payable returns (uint256) {
        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= _fee, "!fee");

        // refund fee to caller if paid too much.
        if (paid > _fee) {
            payable(msg.sender).transfer(paid - _fee);
        }

        return
            MessageDockBase(dockAddress).send{value: _fee}(
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
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external {
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
