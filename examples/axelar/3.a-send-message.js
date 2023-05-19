const { deployReceiver } = require("../helper");
const hre = require("hardhat");
const { getMsgport, DockType } = require("../../dist/index");

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  // Deploy receiver
  hre.changeNetwork(receiverChain);
  const receiverAddress = "0x347d0Cd647A2b4B70000072295A6e35C54B6CCf0"; //await deployReceiver(receiverChain);
  const receiverChainId = (await hre.ethers.provider.getNetwork())["chainId"];
  console.log(
    `On ${receiverChain}, chain id: ${receiverChainId}, receiver address: ${receiverAddress}`
  );

  // Send message to receiver
  hre.changeNetwork(senderChain);
  //  1. get msgport
  const msgport = await getMsgport(
    await hre.ethers.getSigner(),
    "0x067442c619147f73c2cCdeC5A80A3B0DBD5dff34" // <------- change this
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
