const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, LayerZeroDock deployed to: 0x98845062E9D4fF5e52C942Dc6876037A2448DA64
// On polygonTestnet, LayerZeroDock deployed to: 0xE80266BDfF9CD848309a2A5580f7695fa496c40d
// LayerZero Endpoints:
// https://layerzero.gitbook.io/docs/technical-reference/testnet/testnet-addresses
async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0xeF1c60AB9B902c13585411dC929005B98Ca44541"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0xA78aBD4CDAbCAf1A3Ae3F9105195E2c05810EE6E"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const senderDockName = "LayerZeroDock";
  const senderDockParams = [
    "0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1", // sender lzEndpoint
  ];

  const senderDock = await deployDock(
    senderDockName,
    senderMsgportAddress,
    senderChainIdMapping,
    senderDockParams,
    ChainId.POLYGON_MUMBAI
  );
  console.log(
    `On ${senderChain}, ${senderDockName} deployed to: ${senderDock.address}`
  );

  ///////////////////////////////////////
  // deploy receiver dock
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);

  const receiverMsgportAddress = "0x122e4b302a11ABb9Bb6f267B09f2AE77fF9a0B5B"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0xAFb5F12C5F379431253159fae464572999E78485"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const receiverDockName = "LayerZeroDock";
  const receiverDockParams = [
    "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8", // receiver lzEndpoint
  ];

  const receiverDock = await deployDock(
    receiverDockName,
    receiverMsgportAddress,
    receiverChainIdMapping,
    receiverDockParams,
    ChainId.BNBCHAIN_TESTNET
  );
  console.log(
    `On ${receiverChain}, ${receiverDockName} deployed to: ${receiverDock.address}`
  );

  ///////////////////////////////////////
  // connect docks
  ///////////////////////////////////////
  // Add remote Dock to receiver
  await receiverDock.newOutboundLane(
    ChainId.BNBCHAIN_TESTNET,
    senderDock.address
  );
  // let trustedRemote = hre.ethers.utils.solidityPack(
  //   ["address", "address"],
  //   [senderDock.address, receiverDock.address]
  // );
  // const chainIdMapping = await receiverDock.chainIdMapping();
  await receiverDock.setTrustedRemoteAddress(10102, senderDock.address);

  // Add remote Dock to sender
  hre.changeNetwork(senderChain);
  await senderDock.newOutboundLane(
    ChainId.POLYGON_MUMBAI,
    receiverDock.address
  );
  await senderDock.setTrustedRemoteAddress(10109, receiverDock.address);
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
