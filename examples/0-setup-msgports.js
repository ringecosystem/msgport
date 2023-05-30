const hre = require("hardhat");
const { deployMsgport } = require("./helper");
const { ChainId } = require("../dist/src/index");

// On fantomTestnet, msgport deployed to: 0x8FB4916669775c111dBC094F79941CaC1642C943
// On moonbaseAlpha, msgport deployed to: 0xf27C964bF5e0939feD71b1c063A36175192ef754
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
