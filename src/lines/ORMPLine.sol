// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "ORMP/src/interfaces/IEndpoint.sol";
import "ORMP/src/user/Application.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ORMPLine is BaseMessageLine, Application, LineLookup, Ownable2Step {
    constructor(address dao, address ormp, string memory name) BaseMessageLine(name) Application(ormp) {
        _transferOwnership(dao);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function clearFailedMessage(Message calldata message) external onlyOwner {
        _clearFailedMessage(message);
    }

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

    function _send(address fromDapp, uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        internal
        override
    {
        bytes memory encoded = abi.encodeWithSelector(ORMPLine.recv.selector, fromDapp, toDapp, message);
        IEndpoint(TRUSTED_ORMP).send{value: msg.value}(toChainId, _toLine(toChainId), encoded, params);
    }

    function recv(address fromDapp, address toDapp, bytes calldata message) external {
        uint256 fromChainId = _fromChainId();
        require(_xmsgSender() == _fromLine(fromChainId), "!auth");
        _recv(fromChainId, fromDapp, toDapp, message);
    }

    function fee(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params)
        external
        view
        override
        returns (uint256)
    {
        bytes memory encoded = abi.encodeWithSelector(ORMPLine.recv.selector, msg.sender, toDapp, message);
        return IEndpoint(TRUSTED_ORMP).fee(toChainId, toDapp, encoded, params);
    }
}
