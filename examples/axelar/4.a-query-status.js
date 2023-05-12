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
    "0x88e1c783954d0cbccb02cf9c5b8d420b185b7fc485907cf8bea92c2c3f48c484"; // <------- change this
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);

  // query the receiver's result
  // --------------------------------------
  const receiverChain = "moonbaseAlpha";
  const receiverAddress = "0xAFb5F12C5F379431253159fae464572999E78485"; // <------- change this

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
