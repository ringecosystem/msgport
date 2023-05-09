// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9;

import "../../interfaces/IMsgport.sol";

contract S2sPangolinDapp {
    address public msgportAddress;

    constructor(address _msgportAddress) {
        msgportAddress = _msgportAddress;
    }

    function remoteAdd(address pangoroDapp) external payable {
        bytes memory message = abi.encode(uint256(2));
        IMsgport(msgportAddress).send{value: msg.value}(
            pangoroDapp,
            message,
            50_000,
            2457757432886
        );
    }
}
