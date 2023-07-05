const hre = require("hardhat");
const { deployMsgport } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, msgport deployed to: 0x9e974C1a82CF5893f9409a323Fe391263fcB3c4d
// On polygonTestnet, msgport deployed to: 0xC4800a80f1f1974ab70Ee2BC2C58e622f0dD906C
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
