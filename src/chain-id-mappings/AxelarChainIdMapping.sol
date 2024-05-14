// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AxelarChainIdMapping {
    error PortRegistryChainIdNotFound(uint256 portRegistryChainId);
    error AxelarChainIdNotFound(string axelarChainId);

    mapping(uint256 => string) public downMapping;
    mapping(string => uint256) public upMapping;

    constructor(uint256[] memory _portRegistryChainIds, string[] memory _axelarChainIds) {
        require(_portRegistryChainIds.length == _axelarChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _portRegistryChainIds.length; i++) {
            _setChainIdMap(_portRegistryChainIds[i], _axelarChainIds[i]);
        }
    }

    function _setChainIdMap(uint256 _portRegistryChainId, string memory _axelarChainId) internal {
        downMapping[_portRegistryChainId] = _axelarChainId;
        upMapping[_axelarChainId] = _portRegistryChainId;
    }

    function down(uint256 portRegistryChainId) internal view returns (string memory axelarChainId) {
        axelarChainId = downMapping[portRegistryChainId];
        if (bytes(axelarChainId).length == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }

    function up(string memory axelarChainId) internal view returns (uint256 portRegistryChainId) {
        portRegistryChainId = upMapping[axelarChainId];
        if (portRegistryChainId == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }
}
