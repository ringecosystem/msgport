const hre = require("hardhat");
const { getMsgport } = require("../../dist/src/index");

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy receiver
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);
  const receiverAddress = "0xd735Bb7a5c2f1Dc9E91dd3257A0E1FcB687d33E0"; //await deployReceiver(receiverChain);
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
    "0x0C2618fdcB0485941f08d5ae3a3fce252BCaac06" // <------- change this, see 0-setup-msgports.js
  );

  //  2. get the dock selection strategy
  const selectLastDock = async (_) =>
    "0xE637F766Dc0d914903F6654c1Ad4ad8097258D25"; // <------- change this to the sender dock address, see 1-deploy-dock.js

  //  3. send message
  let params = hre.ethers.utils.solidityPack(["uint256"], [9000000]);
  const tx = await msgport.send(
    receiverChainId,
    selectLastDock,
    receiverAddress,
    "0x12345678",
    1.5,
    params
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
