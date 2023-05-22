const hre = require("hardhat");
const { deployMsgport, getChainId } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, msgport deployed to: 0x308f61D8a88f010146C4Ec15897ABc1EFc57c80a
// On moonbaseAlpha, msgport deployed to: 0xa2E9301Cc669e7162FCd02cBEC9FDdb010B1dF8E
async function main() {
  ///////////////////////////////////////
  const senderChain = "fantomTestnet";
  hre.changeNetwork(senderChain);

  // deploy fantom msgport
  let addr = await deployMsgport(ChainId.FANTOM_TESTNET);
  console.log(`On ${senderChain}, msgport deployed to: ${addr}`);

  ///////////////////////////////////////
  const receiverChain = "moonbaseAlpha";
  hre.changeNetwork(receiverChain);

  // deploy moonbaseAlpha msgport
  addr = await deployMsgport(ChainId.MOONBASE_ALPHA);
  console.log(`On ${receiverChain}, msgport deployed to: ${addr}`);
}

main();
