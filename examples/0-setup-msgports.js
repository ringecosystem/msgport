const hre = require("hardhat");
const { deployMsgport } = require("./helper");
const { ChainId } = require("../dist/src/index");

// On fantomTestnet, msgport deployed to: 0xEE174FD525A1540d1cCf3fDadfeD172764b4913F
// On moonbaseAlpha, msgport deployed to: 0xcB9c934243D600283077ffa3956127c321C66EA2
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
