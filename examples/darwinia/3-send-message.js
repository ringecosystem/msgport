const hre = require("hardhat");
const { sendMessage } = require("../helper");

async function main() {
  const senderChain = "goerli";
  const receiverChain = "pangolin";
  const senderLineRegistryAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7"; // <------- change this
  const estimateFee = buildEstimateFeeFunction(
    senderChain,
    "0x6c73B30a48Bb633DC353ed406384F73dcACcA5C3" // goerli fee market address
  );

  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  await sendMessage(
    senderChain,
    senderLineRegistryAddress,
    receiverChain,
    receiverAddress,
    "0x12345678",
    estimateFee
  );
}

function buildEstimateFeeFunction(network, feeMarketAddress) {
  hre.changeNetwork(network);
  const abi = ["function market_fee() external view returns (uint256)"];
  const feeMarket = new hre.ethers.Contract(
    feeMarketAddress,
    abi,
    hre.ethers.provider
  );
  return async (_fromDappAddress, _toDappAddress, _messagePayload) => {
    return await feeMarket.market_fee();
  };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
