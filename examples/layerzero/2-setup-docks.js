const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, LayerZeroDock deployed to: 0x6c1D7335a362138e5E5c8831C838a46d88316f5C
// On moonbaseAlpha, LayerZeroDock deployed to: 0x987F0a2B445BF9F1158cA21dc6CF46F4daBb55D6
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x05f8D1E45A04f5D7336c5BcabfCAc54Bd59c97f4"; // <---- This is the sender msgport address from 0-setup-msgports.js
  const senderChainIdMapping = "0xAA87d749d6EF76CfBF64a2eEe5DA0921278Bf10C"; // <---- This is the sender chain id mapping contract address from 1-deploy-chain-id-mapping.js
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

  const receiverMsgportAddress = "0xb22f4ede6C8aEb3574cFC34108ec03b145d515C3"; // <---- This is the receiver msgport address from 0-setup-msgports.js
  const receiverChainIdMapping = "0x970A6C26dAf9db390d99290AF26109243585E2F6"; // <---- This is the receiver chain id mapping contract address from 1-deploy-chain-id-mapping.js
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
