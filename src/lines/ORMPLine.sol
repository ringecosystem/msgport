// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "ORMP/src/interfaces/IORMP.sol";
import "ORMP/src/user/Application.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ORMPLine is BaseMessageLine, Application, LineLookup, Ownable2Step {
    constructor(address dao, address ormp, string memory name) BaseMessageLine(name) Application(ormp) {
        _transferOwnership(dao);
    }

    function setURI(string calldata uri) external onlyOwner {
        _setURI(uri);
    }

    function setAppConfig(address oracle, address relayer) external onlyOwner {
        _setAppConfig(oracle, relayer);
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
        (uint256 gasLimit, address refund, bytes memory ormpParams) = abi.decode(params, (uint256, address, bytes));
        bytes memory encoded = abi.encodeWithSelector(ORMPLine.recv.selector, fromDapp, toDapp, message);
        IORMP(TRUSTED_ORMP).send{value: msg.value}(toChainId, _toLine(toChainId), gasLimit, encoded, refund, ormpParams);
    }

    function recv(address fromDapp, address toDapp, bytes calldata message) external onlyORMP {
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
        (uint256 gasLimit,, bytes memory ormpParams) = abi.decode(params, (uint256, address, bytes));
        bytes memory encoded = abi.encodeWithSelector(ORMPLine.recv.selector, msg.sender, toDapp, message);
        return IORMP(TRUSTED_ORMP).fee(toChainId, address(this), gasLimit, encoded, ormpParams);
    }
}
