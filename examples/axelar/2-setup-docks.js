const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, AxelarDock deployed to: 0x807a3e011DF1785c538Ac6F65252bf740678Ff99
// On moonbaseAlpha, AxelarDock deployed to: 0x3d5F09572DdD5f52A70c32d0EC6F67b4d18e62bB
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0xEE174FD525A1540d1cCf3fDadfeD172764b4913F"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderChainIdMapping = "0x8D7767AEB493d13F8207CCfFf5B9420314567Bc2"; // <---- This is the sender chain id mapping contract address from 0-deploy-chain-id-mapping.js
  const senderDockName = "AxelarDock";
  const senderDockParams = [
    "0x97837985Ec0494E7b9C71f5D3f9250188477ae14", // senderGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // senderGasReceiver
  ];

  const senderDock = await deployDock(
    senderDockName,
    senderMsgportAddress,
    senderChainIdMapping,
    senderDockParams,
    ChainId.MOONBASE_ALPHA
  );
  console.log(
    `On ${senderChain}, ${senderDockName} deployed to: ${senderDock.address}`
  );

  ///////////////////////////////////////
  // deploy receiver dock
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);

  const receiverMsgportAddress = "0xcB9c934243D600283077ffa3956127c321C66EA2"; // <---- This is the receiver msgport address from 1-setup-msgports.js
  const receiverChainIdMapping = "0xF732E38B74d8BcB94bB3024A85567152dE3335F6"; // <---- This is the receiver chain id mapping contract address from 0-deploy-chain-id-mapping.js
  const receiverDockName = "AxelarDock";
  const receiverDockParams = [
    "0x5769D84DD62a6fD969856c75c7D321b84d455929", // receiverGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // receiverGasReceiver
  ];

  const receiverDock = await deployDock(
    receiverDockName,
    receiverMsgportAddress,
    receiverChainIdMapping,
    receiverDockParams,
    ChainId.FANTOM_TESTNET
  );
  console.log(
    `On ${receiverChain}, ${receiverDockName} deployed to: ${receiverDock.address}`
  );

  ///////////////////////////////////////
  // connect docks
  ///////////////////////////////////////
  // Add remote Dock to receiver
  receiverDock.newOutboundLane(ChainId.FANTOM_TESTNET, senderDock.address);
  receiverDock.newInboundLane(ChainId.FANTOM_TESTNET, senderDock.address);

  // Add remote Dock to sender
  hre.changeNetwork(senderChain);
  senderDock.newOutboundLane(ChainId.MOONBASE_ALPHA, receiverDock.address);
  senderDock.newInboundLane(ChainId.MOONBASE_ALPHA, receiverDock.address);
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); //
