const hre = require("hardhat");
const { deployMsgport } = require("./helper");
const { ChainId } = require("../dist/src/index");

// On fantomTestnet, msgport deployed to: 0x05f8D1E45A04f5D7336c5BcabfCAc54Bd59c97f4
// On moonbaseAlpha, msgport deployed to: 0xb22f4ede6C8aEb3574cFC34108ec03b145d515C3
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
