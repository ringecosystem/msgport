const hre = require("hardhat");
const { deployMsgport } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, msgport deployed to: 0x0B9325BBc7F5Be9cA45bB9A8B5C74EaB97788adF
// On polygonTestnet, msgport deployed to: 0x0B9325BBc7F5Be9cA45bB9A8B5C74EaB97788adF
async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  // deploy fantom msgport
  let addr = await deployMsgport(ChainId.BNBCHAIN_TESTNET);
  console.log(`On ${senderChain}, msgport deployed to: ${addr}`);

  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);

  // deploy moonbaseAlpha msgport
  addr = await deployMsgport(ChainId.POLYGON_MUMBAI, { gasLimit: 1500000 });
  console.log(`On ${receiverChain}, msgport deployed to: ${addr}`);
}

main();
