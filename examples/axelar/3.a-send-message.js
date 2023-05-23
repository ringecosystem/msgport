const { deployReceiver } = require("../helper");
const hre = require("hardhat");
const {
  getMsgport,
  DockType,
  createDefaultDockSelectionStrategy,
} = require("../../dist/src/index");

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
    "0x308f61D8a88f010146C4Ec15897ABc1EFc57c80a" // <------- change this, see examples/axelar/1-setup-msgports.js
  );

  //  2. get the default dock selection strategy
  const selectDockFunction = createDefaultDockSelectionStrategy(
    hre.ethers.provider
  );

  //  3. send message
  const tx = await msgport.send(
    receiverChainId,
    selectDockFunction,
    receiverAddress,
    "0x12345678",
    1.1
  );

  console.log(
    `Message sent: https://testnet.axelarscan.io/gmp/${
      (await tx.wait()).transactionHash
    }`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
