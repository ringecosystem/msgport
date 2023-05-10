const hre = require("hardhat");

function buildEstimateFeeFunction(network, messageBusAddress) {
  hre.changeNetwork(network);
  const abi = [
    "function calcFee(bytes calldata _message) external view returns (uint256)",
  ];
  const messageBus = new hre.ethers.Contract(
    messageBusAddress,
    abi,
    hre.ethers.provider
  );
  return async (fromDappAddress, toDappAddress, messagePayload) => {
    return await messageBus.calcFee(
      hre.ethers.utils.defaultAbiCoder.encode(
        ["address", "address", "bytes"],
        [fromDappAddress, toDappAddress, messagePayload]
      )
    );
  };
}

exports.buildEstimateFeeFunction = buildEstimateFeeFunction;
