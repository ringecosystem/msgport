const hre = require("hardhat");
const { getMsgport } = require("../helper");
const {
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} = require("@axelar-network/axelarjs-sdk");

function buildEstimateFeeFunction() {
  const sdk = new AxelarQueryAPI({
    environment: "testnet",
  });
  return async (_fromDappAddress, _toDappAddress, _messagePayload) => {
    const fee = await sdk.estimateGasFee(
      EvmChain.FANTOM,
      EvmChain.POLYGON,
      GasToken.FTM
    );

    return parseInt(fee);
  };
}

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "polygonTestnet";

  const fantomMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";

  // Deploy receiver
  hre.changeNetwork(receiverChain);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`receiver: ${receiver.address}`);

  // Send message to receiver
  const estimateFee = buildEstimateFeeFunction();
  const msgport = await getMsgport(senderChain, fantomMsgportAddress);
  msgport.send(receiver.address, "0x12345678", estimateFee);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
