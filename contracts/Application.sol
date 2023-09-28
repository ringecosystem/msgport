// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

abstract contract Application {
    address public immutable LINE_REGISTRY;

    constructor(address lineRegistry) {
        LINE_REGISTRY = lineRegistry;
    }


    function isLineRegistry(address lineRegistry) public view returns (bool) {
        return LINE_REGISTRY == lineRegistry;
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
        require(msg.data.length >= 40 && isLineRegistry(msg.sender), "!xmsgSender");
        assembly {
            _from := shr(96, calldataload(sub(calldatasize(), 40)))
        }
    }

    function _lineAddress() internal pure returns (address payable _line) {
        require(msg.data.length >= 20, "!line");
        assembly {
            _line := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
}
