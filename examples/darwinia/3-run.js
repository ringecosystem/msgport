const hre = require("hardhat");
const { getMsgport } = require("../helper");

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

async function main() {
  const senderChain = "goerli";
  const receiverChain = "pangolin";

  const goerliMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";

  // Deploy receiver
  hre.changeNetwork(receiverChain);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`receiver: ${receiver.address}`);

  // Send message to receiver
  const estimateFee = buildEstimateFeeFunction(
    senderChain,
    "0x6c73B30a48Bb633DC353ed406384F73dcACcA5C3" // goerli fee market address
  );
  const msgport = await getMsgport(senderChain, goerliMsgportAddress);
  msgport.send(receiver.address, "0x12345678", estimateFee);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
