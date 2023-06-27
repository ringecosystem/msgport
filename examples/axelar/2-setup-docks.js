const hre = require("hardhat");
const { deployDock } = require("../helper");
const { ChainId } = require("../../dist/src/index");

// On fantomTestnet, AxelarDock deployed to: 0xE637F766Dc0d914903F6654c1Ad4ad8097258D25
// On moonbaseAlpha, AxelarDock deployed to: 0x2D28db6eACF8B4cC03e64FA9B423109a813Fd95C
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy sender dock
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);

  const senderMsgportAddress = "0x0C2618fdcB0485941f08d5ae3a3fce252BCaac06"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderChainIdMapping = "0x413d48524021A95c463A97c50d57F097027D5E42"; // <---- This is the sender chain id mapping contract address from 0-deploy-chain-id-mapping.js
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

  const receiverMsgportAddress = "0xC86f6c6D1E9959E93EE3a8E7CC02BC116e7bb9C3"; // <---- This is the receiver msgport address from 1-setup-msgports.js
  const receiverChainIdMapping = "0x0DDB551bb20988b44640BAC6548FF508FD31d69e"; // <---- This is the receiver chain id mapping contract address from 0-deploy-chain-id-mapping.js
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
    ChainId.FANTOM_TESTNET,
    4000000,
    20000000000,
    4000000
  );
  console.log(
    `On ${receiverChain}, ${receiverDockName} deployed to: ${receiverDock.address}`
  );

  ///////////////////////////////////////
  // connect docks
  ///////////////////////////////////////

  await (
    await receiverDock.newOutboundLane(
      ChainId.FANTOM_TESTNET,
      senderDock.address
    )
  ).wait();
  await (
    await receiverDock.newInboundLane(
      ChainId.FANTOM_TESTNET,
      senderDock.address
    )
  ).wait();
  
  console.log("Set receiver lanes done.")

  // Add remote Dock to sender
  hre.changeNetwork(senderChain);
  await (
    await senderDock.newOutboundLane(
      ChainId.MOONBASE_ALPHA,
      receiverDock.address
    )
  ).wait();
  await (
    await senderDock.newInboundLane(
      ChainId.MOONBASE_ALPHA,
      receiverDock.address
    )
  ).wait();
  console.log("Set sender lanes done.")
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
