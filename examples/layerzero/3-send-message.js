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
  const receiverAddress = "0xe13084f8fF65B755E37d95F49edbD49ca26feE13"; // await deployReceiver(receiverChain);
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
    "0xB5A96e55De950601E8759dF2Be396eA34dADa717"; // <------- change this to the sender line address, see 2-deploy-line.js

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
