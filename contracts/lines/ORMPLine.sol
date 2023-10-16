// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "ORMP/interfaces/IEndpoint.sol";
import "ORMP/user/Application.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ORMPLine is BaseMessageLine, Application, LineLookup, Ownable2Step {
    constructor(address ormp, Metadata memory metadata) BaseMessageLine(metadata) Application(ormp) {}

    function setToLine(uint256 _toChainId, address _toLineAddress) external onlyOwner {
        _setToLine(_toChainId, _toLineAddress);
    }

    function setFromLine(uint256 _fromChainId, address _fromLineAddress) external onlyOwner {
        _setFromLine(_fromChainId, _fromLineAddress);
    }

    function _toLine(uint256 toChainId) internal view returns (address) {
        return toLineLookup[toChainId];
    }

    function _fromLine(uint256 fromChainId) internal view returns (address) {
        return fromLineLookup[fromChainId];
    }

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes memory message, bytes memory params)
        internal
        override
    {
        bytes memory encoded = abi.encodeWithSelector(ORMPLine.recv.selector, fromDapp, toDapp, message);
        IEndpoint(TRUSTED_ORMP).send{value: msg.value}(toChainId, _toLine(toChainId), encoded, params);
    }

    function recv(address fromDapp, address toDapp, bytes memory message) external {
        uint256 fromChainId = _fromChainId();
        require(_xmsgSender() == _fromLine(fromChainId), "!auth");
        _recv(fromChainId, fromDapp, toDapp, message);
    }
}