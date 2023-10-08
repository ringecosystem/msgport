// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Application {
    function _msgSender() internal view returns (address payable _line) {
        _line = payable(msg.sender);
    }

    function _messageId() internal pure returns (bytes32 _msgDataMessageId) {
        require(msg.data.length >= 84, "!messageId");
        assembly {
            _msgDataMessageId := calldataload(sub(calldatasize(), 84))
        }
    }

    function _fromChainId() internal pure returns (uint256 _msgDataFromChainId) {
        require(msg.data.length >= 52, "!fromChainId");
        assembly {
            _msgDataFromChainId := calldataload(sub(calldatasize(), 52))
        }
    }

    function _xmsgSender() internal pure returns (address payable _from) {
        require(msg.data.length >= 20, "!line");
        assembly {
            _from := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
}
