const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, LayerZeroDock deployed to: 0xB822E12dD225FBef8763325Aaf6F2cbCFe331c83
// On moonbaseAlpha, LayerZeroDock deployed to: 0xbEdd6D793D4B06512243072fd0D28722F994e2e3
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x8FB4916669775c111dBC094F79941CaC1642C943"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0xF72C04C06513Af687CFaDbFcEe486E2ac156158D"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const senderDockName = "LayerZeroDock";
  const senderDockParams = [
    "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf", // sender lzEndpoint
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

  const receiverMsgportAddress = "0xf27C964bF5e0939feD71b1c063A36175192ef754"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0x9286b7e01bA7d1157252c5cB1c1066E00F88f5Db"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
  const receiverDockName = "LayerZeroDock";
  const receiverDockParams = [
    "0xb23b28012ee92E8dE39DEb57Af31722223034747", // receiver lzEndpoint
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
  receiverDock.addRemoteDock(ChainId.FANTOM_TESTNET, senderDock.address);

  // Add remote Dock to sender
  hre.changeNetwork(senderChain);
  senderDock.addRemoteDock(ChainId.MOONBASE_ALPHA, receiverDock.address);
  console.log(`Connected`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
