const hre = require("hardhat");
const { deployMsgport } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, msgport deployed to: 0xeF1c60AB9B902c13585411dC929005B98Ca44541
// On polygonTestnet, msgport deployed to: 0x122e4b302a11ABb9Bb6f267B09f2AE77fF9a0B5B
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
