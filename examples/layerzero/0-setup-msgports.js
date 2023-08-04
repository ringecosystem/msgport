const hre = require("hardhat");
const { deployMsgport } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, msgport deployed to: 0xE2B08A0cfCcb40eEfd5254814aF02051Fe6a546a
// On polygonTestnet, msgport deployed to: 0x1D612F014BC3a1e7980dD0aE12D0d3d240864e83
async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  // deploy bnbChainTestnet msgport
  let addr = await deployMsgport(ChainId.BNBCHAIN_TESTNET);
  console.log(`On ${senderChain}, msgport deployed to: ${addr}`);

  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);

  // deploy polygonTestnet msgport
  addr = await deployMsgport(ChainId.POLYGON_MUMBAI, { gasLimit: 1500000 });
  console.log(`On ${receiverChain}, msgport deployed to: ${addr}`);
}

main();
