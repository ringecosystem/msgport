// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "./interfaces/IMsgport.sol";
import "./interfaces/IMessageReceiver.sol";
import "./interfaces/BaseMessageDock.sol";
import "./interfaces/IDockSelectionStrategy.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DefaultMsgport is IMsgport, Ownable2Step {
    struct DappConfig {
        address dockSelectionStrategy;
    }

    uint public immutable localChainId;

    // dapp address => dapp config
    mapping(address => DappConfig) public dappConfigs;

    DappConfig public defaultDappConfig;

    // target chain id => dock addresses
    mapping(uint => address[]) public dockAddresses;

    event DockAdded(uint localChainId, address newDockAddress);

    constructor(uint _localChainId, address defaultDockSelectionStrategy) {
        localChainId = _localChainId;
        defaultDappConfig = DappConfig(defaultDockSelectionStrategy);
    }

    function setDefaultDappConfig(
        address _dockSelectionStrategyAddress
    ) external onlyOwner {
        defaultDappConfig = DappConfig(_dockSelectionStrategyAddress);
    }

    /// Add dock address for a target chain.
    /// TODO: support multiple dock addresses for a target chain.
    ///
    /// @param _toChainId Target chain id.
    /// @param _dockAddress Dock address.
    function addDock(uint _toChainId, address _dockAddress) external onlyOwner {
        require(_toChainId != localChainId, "!localChainId");
        address[] memory dockAddressesToChain = dockAddresses[_toChainId];
        for (uint i = 0; i < dockAddressesToChain.length; i++) {
            require(dockAddressesToChain[i] != _dockAddress, "!dockAddress");
        }

        dockAddresses[_toChainId].push(_dockAddress);
        emit DockAdded(_toChainId, _dockAddress);
    }

    function getLocalChainId() external view override returns (uint) {
        return localChainId;
    }

    function getDockAddress(uint _toChainId) public view returns (address) {
        // get dapp config.
        DappConfig memory dappConfig;
        if (dappConfigs[msg.sender].dockSelectionStrategy == address(0)) {
            dappConfig = defaultDappConfig;
        } else {
            dappConfig = dappConfigs[msg.sender];
        }

        // get dock by dapp's selection strategy.
        address[] memory dockAddressesToChain = dockAddresses[_toChainId];
        address dockAddress = IDockSelectionStrategy(
            dappConfig.dockSelectionStrategy
        ).best(msg.sender, dockAddressesToChain);
        require(dockAddress != address(0), "!dockAddress");

        return dockAddress;
    }

    // called by Dapp.
    function send(
        uint _toChainId,
        address _toDappAddress,
        bytes memory _messagePayload,
        uint256 _fee,
        bytes memory _params
    ) external payable returns (uint256) {
        require(_toChainId != localChainId, "!localChainId");

        // get dock
        address dockAddress = getDockAddress(_toChainId);

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= _fee, "!fee");

        // refund fee to caller if paid too much.
        if (paid > _fee) {
            payable(msg.sender).transfer(paid - _fee);
        }

        return
            BaseMessageDock(dockAddress).send{value: _fee}(
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
        uint _fromChainId,
        address _fromDappAddress,
        address _toDappAddress,
        bytes memory _messagePayload
    ) external {
        // check dock exists in the dockAddresses
        address[] memory dockAddressesFromChain = dockAddresses[_fromChainId];
        for (uint i = 0; i < dockAddressesFromChain.length; i++) {
            require(dockAddressesFromChain[i] != address(0), "!dock");
        }

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
