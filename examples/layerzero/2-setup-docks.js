const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, LayerZeroDock deployed to: 0xE5119671d15AF42e3665c4d656d44996D7136144
// On moonbaseAlpha, LayerZeroDock deployed to: 0xD7226dD7c502D0d3242115e2C23Ed3C79b4A3387
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x0B9325BBc7F5Be9cA45bB9A8B5C74EaB97788adF"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0x1D612F014BC3a1e7980dD0aE12D0d3d240864e83"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
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

  const receiverMsgportAddress = "0xF5dCBc6745dB59ce5936291AfF756b9c0BBa6678"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0xFe89354a5ee07F66D9fB0DB2aDa67c1F09eF286c"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
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
