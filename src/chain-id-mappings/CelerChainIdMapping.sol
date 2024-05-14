// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CelerChainIdMapping {
    error PortRegistryChainIdNotFound(uint256 portRegistryChainId);
    error CelerChainIdNotFound(uint64 celerChainId);

    mapping(uint256 => uint64) public downMapping;
    mapping(uint64 => uint256) public upMapping;

    constructor(uint256[] memory _portRegistryChainIds, uint64[] memory _celerChainIds) {
        require(_portRegistryChainIds.length == _celerChainIds.length, "Lengths do not match.");

        for (uint256 i = 0; i < _portRegistryChainIds.length; i++) {
            _setChainIdMap(_portRegistryChainIds[i], _celerChainIds[i]);
        }
    }

    function _setChainIdMap(uint256 _portRegistryChainId, uint64 _celerChainId) internal {
        downMapping[_portRegistryChainId] = _celerChainId;
        upMapping[_celerChainId] = _portRegistryChainId;
    }

    function down(uint256 portRegistryChainId) internal view returns (uint64 celerChainId) {
        celerChainId = downMapping[portRegistryChainId];
        if (celerChainId == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }

    function up(uint64 celerChainId) internal view returns (uint256 portRegistryChainId) {
        portRegistryChainId = upMapping[celerChainId];
        if (portRegistryChainId == 0) {
            revert PortRegistryChainIdNotFound(portRegistryChainId);
        }
    }
}
