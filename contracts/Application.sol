// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Application {
    address public immutable MESSAGE_PORT;

    constructor(address msgPort) {
        MESSAGE_PORT = msgPort;
    }


    function isMessagePort(address msgPort) public view returns (bool) {
        return MESSAGE_PORT == msgPort;
    }

    function _messageId() internal pure returns (bytes32 _msgDataMessageId) {
        require(msg.data.length >= 104, "!messageId");
        assembly {
            _msgDataMessageId := calldataload(sub(calldatasize(), 104))
        }
    }

    function _fromChainId() internal pure returns (uint256 _msgDataFromChainId) {
        require(msg.data.length >= 72, "!fromChainId");
        assembly {
            _msgDataFromChainId := calldataload(sub(calldatasize(), 72))
        }
    }

    function _xmsgSender() internal view returns (address payable _from) {
        require(msg.data.length >= 40 && isMessagePort(msg.sender), "!xmsgSender");
        assembly {
            _from := shr(96, calldataload(sub(calldatasize(), 40)))
        }
    }

    function _lineAddress() internal view returns (address payable _line) {
        require(msg.data.length >= 20, "!line");
        assembly {
            _from := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
}
