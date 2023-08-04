const { deployReceiver } = require("../helper");
const hre = require("hardhat");
const { getMsgport } = require("../../dist/src/index");

async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  // deploy receiver
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);
  const receiverAddress = "0xD7226dD7c502D0d3242115e2C23Ed3C79b4A3387"; 
  // const receiverAddress = await deployReceiver(receiverChain); console.log(receiverAddress);
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
    "0xE2B08A0cfCcb40eEfd5254814aF02051Fe6a546a" // <------- change this, see 0-setup-msgports.js
  );

  //  2. get the line selection strategy
  const selectLastLine = async (_) =>
    "0x03836d459E753335F65D79e441ba4354E3a736D4"; // <------- change this to the sender line address, see 2-deploy-line.js

  //  3. send message
  // https://layerzero.gitbook.io/docs/evm-guides/advanced/relayer-adapter-parameters
  let params = hre.ethers.utils.solidityPack(
    ["uint16", "uint256"],
    [1, 300000]
  );
  const tx = await msgport.send(
    receiverChainId,
    selectLastLine,
    receiverAddress,
    "0x1234",
    1.1,
    params
  );

  console.log(
    `Message sent: https://testnet.layerzeroscan.com/tx/${
      (await tx.wait()).transactionHash
    }`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
