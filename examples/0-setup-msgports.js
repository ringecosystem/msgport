const hre = require("hardhat");
const { deployLineRegistry } = require("./helper");
const { ChainId } = require("../dist/src/index");

// On fantomTestnet, lineRegistry deployed to: 0xEE174FD525A1540d1cCf3fDadfeD172764b4913F
// On moonbaseAlpha, lineRegistry deployed to: 0xcB9c934243D600283077ffa3956127c321C66EA2
async function main() {
  ///////////////////////////////////////
  const senderChain = "fantomTestnet";
  hre.changeNetwork(senderChain);

  // deploy fantom lineRegistry
  let addr = await deployLineRegistry(ChainId.FANTOM_TESTNET);
  console.log(`On ${senderChain}, lineRegistry deployed to: ${addr}`);

  ///////////////////////////////////////
  const receiverChain = "moonbaseAlpha";
  hre.changeNetwork(receiverChain);

  // deploy moonbaseAlpha lineRegistry
  addr = await deployLineRegistry(ChainId.MOONBASE_ALPHA);
  console.log(`On ${receiverChain}, lineRegistry deployed to: ${addr}`);
}

main();
