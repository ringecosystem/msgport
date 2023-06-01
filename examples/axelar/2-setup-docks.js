const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, AxelarDock deployed to: 0x20aE788f9E9F380Aa9d241e69Dfd816E078cE1e1
// On moonbaseAlpha, AxelarDock deployed to: 0x771E962b7Ecc66362BE3aA737BD0919744aa3C11
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0xEE174FD525A1540d1cCf3fDadfeD172764b4913F"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderChainIdMapping = "0x7e75c06A6a79d35Cb6D4bE96c2626FBBFe37d548"; // <---- This is the sender chain id mapping contract address from 0-deploy-chain-id-mapping.js
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
  const receiverChainIdMapping = "0xa1333f4749F5A808bbaCa735E95c4DB77573A14A"; // <---- This is the receiver chain id mapping contract address from 0-deploy-chain-id-mapping.js
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

  // Add remote Dock to sender
  hre.changeNetwork(senderChain);
  senderDock.newOutboundLane(ChainId.MOONBASE_ALPHA, receiverDock.address);
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
}); //
