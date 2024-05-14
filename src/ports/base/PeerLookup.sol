// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract PeerLookup {
    // chainId => peer
    mapping(uint256 => address) internal _peers;

    event PeerSet(uint256 chainId, address peer);

    function peerOf(uint256 chainId) public view virtual returns (address) {
        return _peers[chainId];
    }

    function _setPeer(uint256 chainId, address peer) internal virtual {
        _peers[chainId] = peer;
        emit PeerSet(chainId, peer);
    }

    function _checkedPeerOf(uint256 chainId) internal view virtual returns (address p) {
        p = _peers[chainId];
        require(p != address(0), "!peer");
    }
}
