const { deployReceiver } = require("../helper");
const hre = require("hardhat");
const { getMsgport, DockType } = require("../../dist/index");

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy receiver
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);
  const receiverAddress = await deployReceiver(receiverChain);
  const receiverChainId = (await hre.ethers.provider.getNetwork())["chainId"];
  console.log(
    `On ${receiverChain}, chain id: ${receiverChainId}, receiver address: ${receiverAddress}`
  );

  ///////////////////////////////////////
  // send message to receiver
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);
  //  1. get msgport
  const msgport = await getMsgport(
    await hre.ethers.getSigner(),
    "0x565d2e330F0124aa471Be339b340C410C5f04B57" // <------- change this
  );

  //  2. send message
  await msgport.send(
    receiverChainId,
    receiverAddress,
    "0x12345678",
    DockType.AxelarTestnet // this is used to look up the chain specific estimateFee function
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
