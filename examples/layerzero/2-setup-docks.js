const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, LayerZeroDock deployed to: 0x3d5F09572DdD5f52A70c32d0EC6F67b4d18e62bB
// On polygonTestnet, LayerZeroDock deployed to: 0xDBcDC65fedea270ab1d213e865F689e45eeF7f47
// LayerZero Endpoints:
// https://layerzero.gitbook.io/docs/technical-reference/testnet/testnet-addresses
async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x9e974C1a82CF5893f9409a323Fe391263fcB3c4d"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0x771E962b7Ecc66362BE3aA737BD0919744aa3C11"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
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

  const receiverMsgportAddress = "0xC4800a80f1f1974ab70Ee2BC2C58e622f0dD906C"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0xd735Bb7a5c2f1Dc9E91dd3257A0E1FcB687d33E0"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
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
  await (
    await receiverDock.newOutboundLane(
      ChainId.BNBCHAIN_TESTNET,
      senderDock.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("1----------");
  await (
    await receiverDock.newInboundLane(
      ChainId.BNBCHAIN_TESTNET,
      senderDock.address,
      { gasLimit: 100000 }
    )
  ).wait();

  console.log("2----------");
  let trustedRemote = hre.ethers.utils.solidityPack(
    ["address", "address"],
    [senderDock.address, receiverDock.address]
  );
  // const chainIdMapping = await receiverDock.chainIdMapping();
  await (
    await receiverDock.setTrustedRemote(10102, trustedRemote, {
      gasLimit: 100000,
    })
  ).wait();

  // Add remote Dock to sender
  hre.changeNetwork(senderChain);
  console.log("3----------");
  await (
    await senderDock.newOutboundLane(
      ChainId.POLYGON_MUMBAI,
      receiverDock.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("4----------");
  await (
    await senderDock.newInboundLane(
      ChainId.POLYGON_MUMBAI,
      receiverDock.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("5----------");
  let trustedRemote2 = hre.ethers.utils.solidityPack(
    ["address", "address"],
    [receiverDock.address, senderDock.address]
  );
  await (
    await senderDock.setTrustedRemote(10109, trustedRemote2, {
      gasLimit: 100000,
    })
  ).wait();
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
