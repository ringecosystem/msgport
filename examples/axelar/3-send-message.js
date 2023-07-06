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
    "0xEE174FD525A1540d1cCf3fDadfeD172764b4913F" // <------- change this, see 0-setup-msgports.js
  );

  //  2. get the line selection strategy
  const selectLastLine = async (_) =>
    "0x807a3e011DF1785c538Ac6F65252bf740678Ff99"; // <------- change this to the sender line address, see 1-deploy-line.js

  //  3. send message
  let params = hre.ethers.utils.solidityPack(["uint256"], [1000000]);
  const tx = await msgport.send(
    receiverChainId,
    selectLastLine,
    receiverAddress,
    "0x12345678",
    1.1,
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
