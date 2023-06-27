const hre = require("hardhat");
const { deployMsgport } = require("./helper");
const { ChainId } = require("../dist/src/index");

// On fantomTestnet, msgport deployed to: 0x0C2618fdcB0485941f08d5ae3a3fce252BCaac06
// On moonbaseAlpha, msgport deployed to: 0xC86f6c6D1E9959E93EE3a8E7CC02BC116e7bb9C3
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
