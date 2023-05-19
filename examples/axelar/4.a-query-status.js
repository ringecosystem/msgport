const {
  AxelarGMPRecoveryAPI,
  Environment,
} = require("@axelar-network/axelarjs-sdk");
const hre = require("hardhat");

async function main() {
  // query the cross chain message status
  // --------------------------------------
  const sdk = new AxelarGMPRecoveryAPI({
    environment: Environment.TESTNET,
  });
  const txHash =
    "0xc9e1764be86d31d8220eecc9e58dd50c0f889b1d3ccdf039e7fbad4c4cb82872"; // <------- change this
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);

  // query the receiver's result
  // --------------------------------------
  const receiverChain = "moonbaseAlpha";
  const receiverAddress = "0x347d0Cd647A2b4B70000072295A6e35C54B6CCf0"; // <------- change this

  hre.changeNetwork(receiverChain);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.attach(receiverAddress);
  const message = await receiver.message();
  console.log(`received message: ${message}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
