const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, AxelarDock deployed to: 0xE447B04655a1EaA0fE35C2aD126667CDa458b4aD
// On moonbaseAlpha, AxelarDock deployed to: 0xE80266BDfF9CD848309a2A5580f7695fa496c40d
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x308f61D8a88f010146C4Ec15897ABc1EFc57c80a"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderChainIdMapping = "0xd9d42206AcC2d5c3860Cc3992F6A0E61E4f587F6"; // <---- This is the sender chain id mapping contract address from 0-deploy-chain-id-mapping.js
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

  const receiverMsgportAddress = "0xa2E9301Cc669e7162FCd02cBEC9FDdb010B1dF8E"; // <---- This is the receiver msgport address from 1-setup-msgports.js
  const receiverChainIdMapping = "0x06B74269f991593eA2f42B23b0B87A3f1C5BA5C1"; // <---- This is the receiver chain id mapping contract address from 0-deploy-chain-id-mapping.js
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
