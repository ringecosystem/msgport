const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, LayerZeroDock deployed to: 0x0C9549C21313cEdEb794816c534Dc71B0D94A21b
// On polygonTestnet, LayerZeroDock deployed to: 0x0C9549C21313cEdEb794816c534Dc71B0D94A21b
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
  const senderChainIdMapping = "0x7Ac2cd64B0F9DF41694E917CC436D1392ad91152"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
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
  const receiverChainIdMapping = "0x26a4fAE216359De954a927dEbaB339C09Dbf7e8e"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
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
