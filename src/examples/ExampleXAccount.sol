// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev IXAccountFactory represents a factory contract responsible for the creation of xAccounts.
interface IXAccountFactory {
    /// @dev Cross chian function for create xAccount on target chain.
    /// @notice If recovery address is `address(0)`, do not enabale recovery module.
    /// @param code Port code that used for create xAccount.
    /// @param toChainId Target chain id.
    /// @param params Port params correspond with the port.
    /// @param recovery The default safe recovery module address on target chain for xAccount.
    function xCreate(bytes4 code, uint256 toChainId, bytes calldata params, address recovery) external payable;
    /// @dev Calculate xAccount address on target chain.
    /// @notice The module address is only effective during its creation and may be replaced by the xAccount in the future.
    /// @param fromChainId Chain id that xAccount belongs in.
    /// @param toChainId Chain id that xAccount lives in.
    /// @param deployer Owner that xAccount belongs to.
    /// @return (xAccount address, module address).
    function xAccountOf(uint256 fromChainId, uint256 toChainId, address deployer)
        external
        view
        returns (address, address);
}

/// @dev ISafeMsgportModule serves as a module integrated within the Safe system, specifically devised to enable remote administration and control of the xAccount.
interface ISafeMsgportModule {
    /// @dev Receive xCall from root chain xOwner.
    /// @param target Target of the transaction that should be executed
    /// @param value Wei value of the transaction that should be executed
    /// @param data Data of the transaction that should be executed
    /// @param operation Operation (Call or Delegatecall) of the transaction that should be executed
    /// @return xExecute return data Return data after xCall.
    function xExecute(address target, uint256 value, bytes calldata data, uint8 operation)
        external
        payable
        returns (bytes memory);
}

/// @dev IPortRegistry functions as a comprehensive registry for all chain message ports.
interface IPortRegistry {
    /// @dev Fetch port address by chainId and port code.
    function get(uint256 chainId, bytes4 code) external view returns (address);
}

/// @dev IMessagePort serves as a universal interface facilitating the transmission of cross-chain messages across all msgport channels.
interface IMessagePort {
    /// @dev Send a cross-chain message over the MessagePort.
    /// @notice Send a cross-chain message over the MessagePort.
    /// @param toChainId The message destination chain id. <https://eips.ethereum.org/EIPS/eip-155>
    /// @param toDapp The user application contract address which receive the message.
    /// @param message The calldata which encoded by ABI Encoding.
    /// @param params Extend parameters to adapt to different message protocols.
    function send(uint256 toChainId, address toDapp, bytes calldata message, bytes calldata params) external payable;
}

/// @dev ExampleXAccount is a demonstration showcasing the utilization of xAccount to execute an xCall.
contract ExampleXAccount {
    // XAccountFactory address
    address public factory;
    // PortRegistry address
    address public registry;

    constructor(address factory_, address registry_) {
        factory = factory_;
        registry = registry_;
    }

    /// @dev The function is utilized to create a xAccount on the target chain.
    function createXAccountOnTargetChain(bytes4 code, uint256 toChainId, bytes calldata params, address recovery)
        public
        payable
    {
        IXAccountFactory(factory).xCreate{value: msg.value}(code, toChainId, params, recovery);
    }

    /// @dev The function facilitates the execution of an xCall across a xAccount.
    function crossChainCall(
        bytes4 code,
        uint256 toChainId,
        bytes calldata params,
        address target,
        uint256 value,
        bytes calldata data,
        uint8 operation
    ) public payable {
        bytes memory message =
            abi.encodeWithSelector(ISafeMsgportModule.xExecute.selector, target, value, data, operation);
        address port = IPortRegistry(registry).get(toChainId, code);
        (, address module) = IXAccountFactory(factory).xAccountOf(block.chainid, toChainId, address(this));
        IMessagePort(port).send{value: msg.value}(toChainId, module, message, params);
    }
}
