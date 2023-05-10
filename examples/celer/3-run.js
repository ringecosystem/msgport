const hre = require("hardhat");
const { getMsgport } = require("../helper");
const { buildEstimateFeeFunction } = require("./celer-helper");

async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "fantomTestnet";

  const bscMsgportAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573";

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
    "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA" // bsc testnet message bus address
  );
  // console.log(
  //   `estimateFee: ${await estimateFee(
  //     "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA",
  //     "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA",
  //     "0x12345678"
  //   )}`
  // );
  const msgport = await getMsgport(senderChain, bscMsgportAddress);
  msgport.send(receiver.address, "0x12345678", estimateFee);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
