const hre = require("hardhat");
const { deployLine } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On bnbChainTestnet, LayerZeroLine deployed to: 0xB5A96e55De950601E8759dF2Be396eA34dADa717
// On polygonTestnet, LayerZeroLine deployed to: 0x6Db337cC418d7A0F2230bc0c6B14813149e39615
// LayerZero Endpoints:
// https://layerzero.gitbook.io/docs/technical-reference/testnet/testnet-addresses
async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  ///////////////////////////////////////
  // deploy sender line
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0xE2B08A0cfCcb40eEfd5254814aF02051Fe6a546a"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0x8D4906C46de7A75eceb7D02B308907596BBEd3bD"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const senderLineName = "LayerZeroLine";
  const senderLineParams = [
    "0x6Fcb97553D41516Cb228ac03FdC8B9a0a9df04A1", // sender lzEndpoint
    {
      name: "LayerZeroLine on bnbChainTestnet",
      provider: "TEST",
      description: "just for test",
      feeEstimation: {
        feeContract: "0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85",
        feeMethod: "estimating",
        offChainFeeApi: "http://123456"
      },
    }
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

  const receiverMsgportAddress = "0x1D612F014BC3a1e7980dD0aE12D0d3d240864e83"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0xE5119671d15AF42e3665c4d656d44996D7136144"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const receiverLineName = "LayerZeroLine";
  const receiverLineParams = [
    "0xf69186dfBa60DdB133E91E9A4B5673624293d8F8", // receiver lzEndpoint
    {
      name: "LayerZeroLine on polygonTestnet",
      provider: "TEST",
      description: "just for test",
      feeEstimation: {
        feeContract: "0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85",
        feeMethod: "estimating2",
        offChainFeeApi: "http://1234562"
      },
    }
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
    await receiverLine.addToLine(
      ChainId.BNBCHAIN_TESTNET,
      senderLine.address,
      { gasLimit: 100000 }
    )).wait()
  console.log("1. Add toLine for receiverLine");

  await (
    await receiverLine.addFromLine(
      ChainId.BNBCHAIN_TESTNET,
      senderLine.address,
      { gasLimit: 100000 }
    )).wait()
  console.log("2. Add fromLine for receiverLine");

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
  await (
    await senderLine.addToLine(
      ChainId.POLYGON_MUMBAI,
      receiverLine.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("3 Add toLine for senderLine");

  await (
    await senderLine.addFromLine(
      ChainId.POLYGON_MUMBAI,
      receiverLine.address,
      { gasLimit: 100000 }
    )
  ).wait();
  console.log("4 Add fromLine for senderLine");

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
