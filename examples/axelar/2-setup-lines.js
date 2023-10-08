const hre = require("hardhat");
const { deployLine } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, AxelarLine deployed to: 0x807a3e011DF1785c538Ac6F65252bf740678Ff99
// On moonbaseAlpha, AxelarLine deployed to: 0x3d5F09572DdD5f52A70c32d0EC6F67b4d18e62bB
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender line
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderLineRegistryAddress = "0xEE174FD525A1540d1cCf3fDadfeD172764b4913F"; // <---- This is the sender lineRegistry address from 1-setup-lineRegistrys.js
  const senderChainIdMapping = "0x8D7767AEB493d13F8207CCfFf5B9420314567Bc2"; // <---- This is the sender chain id mapping contract address from 0-deploy-chain-id-mapping.js
  const senderLineName = "AxelarLine";
  const senderLineParams = [
    "0x97837985Ec0494E7b9C71f5D3f9250188477ae14", // senderGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // senderGasReceiver
  ];

  const senderLine = await deployLine(
    senderLineName,
    senderLineRegistryAddress,
    senderChainIdMapping,
    senderLineParams,
    ChainId.MOONBASE_ALPHA
  );
  console.log(
    `On ${senderChain}, ${senderLineName} deployed to: ${senderLine.address}`
  );

  ///////////////////////////////////////
  // deploy receiver line
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);

  const receiverLineRegistryAddress = "0xcB9c934243D600283077ffa3956127c321C66EA2"; // <---- This is the receiver lineRegistry address from 1-setup-lineRegistrys.js
  const receiverChainIdMapping = "0xF732E38B74d8BcB94bB3024A85567152dE3335F6"; // <---- This is the receiver chain id mapping contract address from 0-deploy-chain-id-mapping.js
  const receiverLineName = "AxelarLine";
  const receiverLineParams = [
    "0x5769D84DD62a6fD969856c75c7D321b84d455929", // receiverGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // receiverGasReceiver
  ];

  const receiverLine = await deployLine(
    receiverLineName,
    receiverLineRegistryAddress,
    receiverChainIdMapping,
    receiverLineParams,
    ChainId.FANTOM_TESTNET
  );
  console.log(
    `On ${receiverChain}, ${receiverLineName} deployed to: ${receiverLine.address}`
  );

  ///////////////////////////////////////
  // connect lines
  ///////////////////////////////////////
  // Add remote Line to receiver
  receiverLine.newOutboundLane(ChainId.FANTOM_TESTNET, senderLine.address);
  receiverLine.newInboundLane(ChainId.FANTOM_TESTNET, senderLine.address);

  // Add remote Line to sender
  hre.changeNetwork(senderChain);
  senderLine.newOutboundLane(ChainId.MOONBASE_ALPHA, receiverLine.address);
  senderLine.newInboundLane(ChainId.MOONBASE_ALPHA, receiverLine.address);
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); //
