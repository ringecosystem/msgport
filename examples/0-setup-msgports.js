const hre = require("hardhat");
const { deployMsgport } = require("./helper");
const { ChainId } = require("../dist/src/index");

// On fantomTestnet, msgport deployed to: 0x0B9325BBc7F5Be9cA45bB9A8B5C74EaB97788adF
// On moonbaseAlpha, msgport deployed to: 0xF5dCBc6745dB59ce5936291AfF756b9c0BBa6678
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
