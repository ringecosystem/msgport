// This file is part of Darwinia.
// Copyright (C) 2018-2023 Darwinia Network
// SPDX-License-Identifier: GPL-3.0
//
// Darwinia is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Darwinia is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Darwinia. If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.8.17;

import "./base/BaseMessageLine.sol";
import "./base/LineLookup.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IOutboundLane.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/IFeeMarket.sol";
import "@darwinia/contracts-periphery/contracts/interfaces/ICrossChainFilter.sol";

import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract DarwiniaLine is BaseMessageLine, LineLookup, ICrossChainFilter, Ownable2Step {
    address public immutable outboundLane;
    address public immutable inboundLane;
    IFeeMarket public immutable feeMarket;

    constructor(
        uint256 _remoteChainId,
        address _remoteLineAddress,
        address _outboundLane,
        address _inboundLane,
        address _feeMarket,
        string memory _name
    ) BaseMessageLine(_name) {
        // add outbound and inbound lane
        _setToLine(_remoteChainId, _remoteLineAddress);
        _setFromLine(_remoteChainId, _remoteLineAddress);
        //
        outboundLane = _outboundLane;
        inboundLane = _inboundLane;
        //
        feeMarket = IFeeMarket(_feeMarket);
    }

    //////////////////////////////////////////
    // override BaseMessageLine
    //////////////////////////////////////////
    // For sending
    function _send(
        address _fromDappAddress,
        uint256 _toChainId,
        address _toDappAddress,
        bytes calldata _messagePayload,
        bytes calldata /*_params*/
    ) internal override {
        // estimate fee on chain
        uint256 fee = feeMarket.market_fee();

        // check fee payed by caller is enough.
        uint256 paid = msg.value;
        require(paid >= fee, "!fee");

        // refund fee
        if (paid > fee) {
            payable(msg.sender).transfer(paid - fee);
        }

        IOutboundLane(outboundLane).send_message{value: fee}(
            toLineLookup[_toChainId],
            abi.encodeWithSignature(
                "recv(uint256,address,address,address,bytes)",
                LOCAL_CHAINID(),
                address(this),
                _fromDappAddress,
                _toDappAddress,
                _messagePayload
            )
        );
    }

    //////////////////////////////////////////
    // implement ICrossChainFilter
    //////////////////////////////////////////
    function cross_chain_filter(
        uint32, /*bridgedChainPosition*/
        uint32, /*bridgedLanePosition*/
        address sourceAccount,
        bytes calldata /*payload*/
    ) external view returns (bool) {
        address remoteLineAddress = fromLineLookup[LOCAL_CHAINID()];
        // check remote line address is set.
        // this check is not necessary, but it can provide an more understandable err.
        require(remoteLineAddress != address(0), "!remote line");

        return sourceAccount == remoteLineAddress;
    }
}
