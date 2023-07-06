const hre = require("hardhat");
const { deployLine } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, LayerZeroLine deployed to: 0x0C9549C21313cEdEb794816c534Dc71B0D94A21b
// On polygonTestnet, LayerZeroLine deployed to: 0x0C9549C21313cEdEb794816c534Dc71B0D94A21b
// LayerZero Endpoints:
// https://layerzero.gitbook.io/docs/technical-reference/testnet/testnet-addresses
async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  // deploy sender line
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x0B9325BBc7F5Be9cA45bB9A8B5C74EaB97788adF"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0x7Ac2cd64B0F9DF41694E917CC436D1392ad91152"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const senderLineName = "LayerZeroLine";
  const senderLineParams = [
    "0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1", // sender lzEndpoint
  ];

  const senderLine = await deployLine(
    senderLineName,
    senderMsgportAddress,
    senderChainIdMapping,
    senderLineParams,
    ChainId.POLYGON_MUMBAI
  );
  console.log(
    `On ${senderChain}, ${senderLineName} deployed to: ${senderLine.address}`
  );

  ///////////////////////////////////////
  // deploy receiver line
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);

  const receiverMsgportAddress = "0x0B9325BBc7F5Be9cA45bB9A8B5C74EaB97788adF"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0x26a4fAE216359De954a927dEbaB339C09Dbf7e8e"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const receiverLineName = "LayerZeroLine";
  const receiverLineParams = [
    "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8", // receiver lzEndpoint
  ];

  const receiverLine = await deployLine(
    receiverLineName,
    receiverMsgportAddress,
    receiverChainIdMapping,
    receiverLineParams,
    ChainId.BNBCHAIN_TESTNET
  );
  console.log(
    `On ${receiverChain}, ${receiverLineName} deployed to: ${receiverLine.address}`
  );

  ///////////////////////////////////////
  // connect lines
  ///////////////////////////////////////
  // Add remote Line to receiver
  await (
    await receiverLine.newOutboundLane(
      ChainId.BNBCHAIN_TESTNET,
      senderLine.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("1----------");
  await (
    await receiverLine.newInboundLane(
      ChainId.BNBCHAIN_TESTNET,
      senderLine.address,
      { gasLimit: 100000 }
    )
  ).wait();

  console.log("2----------");
  let trustedRemote = hre.ethers.utils.solidityPack(
    ["address", "address"],
    [senderLine.address, receiverLine.address]
  );
  // const chainIdMapping = await receiverLine.chainIdMapping();
  await (
    await receiverLine.setTrustedRemote(10102, trustedRemote, {
      gasLimit: 100000,
    })
  ).wait();

  // Add remote Line to sender
  hre.changeNetwork(senderChain);
  console.log("3----------");
  await (
    await senderLine.newOutboundLane(
      ChainId.POLYGON_MUMBAI,
      receiverLine.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("4----------");
  await (
    await senderLine.newInboundLane(
      ChainId.POLYGON_MUMBAI,
      receiverLine.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("5----------");
  let trustedRemote2 = hre.ethers.utils.solidityPack(
    ["address", "address"],
    [receiverLine.address, senderLine.address]
  );
  await (
    await senderLine.setTrustedRemote(10109, trustedRemote2, {
      gasLimit: 100000,
    })
  ).wait();
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
