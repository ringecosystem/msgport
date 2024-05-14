// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../interfaces/ISafe.sol";
import "../user/xAuth.sol";

contract SafeMsgportModule is xAuth {
    address public port;

    address public childXAccount;
    uint256 public rootChainid;
    address public rootOwner;

    event SetPort(address port);
    event ModuleTransactionExecuted(address target, uint256 value, bytes data, Operation operation, bool result);

    error AlreadySetup();
    error ZeroChainId();
    error SendEtherFailed(bytes reason);

    constructor() {
        rootChainid = 1;
    }

    function setup(address xAccount, uint256 chainId, address owner, address port_) external {
        if (rootChainid > 0) {
            revert AlreadySetup();
        }
        if (chainId == 0) {
            revert ZeroChainId();
        }
        port = port_;
        childXAccount = xAccount;
        rootChainid = chainId;
        rootOwner = owner;
        emit SetPort(port_);
    }

    /// @dev Fetch the xAccount xOwner.
    /// @return (chainId, owner)
    ///   - chainId Chain id that xAccount belongs in.
    ///   - owner Owner that xAccount belongs to.
    function xOwner() public view override returns (uint256, address) {
        return (rootChainid, rootOwner);
    }

    /// @dev Check that the xCall originates from the port.
    /// @return Check result.
    function checkPort(address port_) public view override returns (bool) {
        return port == port_;
    }

    /// @dev Set port.
    /// @param port_ New port.
    function setPort(address port_) external {
        _checkXAuth();
        port = port_;
        emit SetPort(port_);
    }

    /// @dev Receive xCall from root chain xOwner.
    /// @param target Target of the transaction that should be executed
    /// @param value Wei value of the transaction that should be executed
    /// @param data Data of the transaction that should be executed
    /// @param operation Operation (Call or Delegatecall) of the transaction that should be executed
    /// @return xExecute return data Return data after xCall.
    function xExecute(address target, uint256 value, bytes calldata data, Operation operation)
        external
        payable
        returns (bytes memory)
    {
        _checkXAuth();
        if (msg.value > 0) {
            (bool s, bytes memory r) = childXAccount.call{value: msg.value}("");
            if (!s) revert SendEtherFailed(r);
        }
        (bool success, bytes memory returnData) =
            ISafe(childXAccount).execTransactionFromModuleReturnData(target, value, data, operation);
        emit ModuleTransactionExecuted(target, value, data, operation, success);
        return returnData;
    }
}
