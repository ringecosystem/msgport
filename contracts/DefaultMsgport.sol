// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./interfaces/IMsgport.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/AbstractMessageChannel.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DefaultMsgport is IMsgport, Ownable2Step {
    address public msgportAddress;
    uint256 public defaultExecutionGas;

    function setAdapter(address _msgportAddress) external onlyOwner {
        msgportAddress = _msgportAddress;
    }

    function estimateFee(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        uint256 _executionGas, // 0 means using defaultExecutionGas
        uint256 _gasPrice
    ) external view returns (uint256) {
        return
            doEstimateFee(
                _fromDappAddress,
                _toDappAddress,
                _messagePayload,
                _executionGas,
                _gasPrice
            );
    }

    function doEstimateFee(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload,
        uint256 _executionGas, // 0 means using defaultExecutionGas
        uint256 _gasPrice
    ) internal view returns (uint256) {
        AbstractMessageChannel channel = AbstractMessageChannel(msgportAddress);

        // fee1: Get the relay fee.
        uint256 relayFee = channel.getRelayFee(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        // fee2: Get the delivery gas. this gas used by lower level layer and msgport.
        uint256 deliveryGas = channel.getDeliveryGas(
            _fromDappAddress,
            _toDappAddress,
            _messagePayload
        );

        // fee3: Get the message execution gas.
        uint256 executionGas = _executionGas == 0
            ? defaultExecutionGas
            : _executionGas;

        return relayFee + (deliveryGas + executionGas) * _gasPrice;
    }

    // called by Dapp.
    function send(
        address _toDappAddress,
        bytes memory _messagePayload,
        uint256 _executionGas, // 0 means using defaultExecutionGas,
        uint256 _gasPrice
    ) external payable returns (uint256) {
        uint256 fee = doEstimateFee(
            msg.sender,
            _toDappAddress,
            _messagePayload,
            _executionGas,
            _gasPrice
        );

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= fee, "!fee");

        // refund fee to caller if paid too much.
        if (paid > fee) {
            payable(msg.sender).transfer(paid - fee);
        }

        return
            AbstractMessageChannel(msgportAddress).send{value: fee}(
                msg.sender,
                _toDappAddress,
                _messagePayload
            );
    }

    // called by channel.
    //
    // catch the error if user's recv function failed with uncaught error.
    // store the message and error for the user to do something like retry.
    function recv(
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external {
        require(msg.sender == msgportAddress, "!channel");
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
