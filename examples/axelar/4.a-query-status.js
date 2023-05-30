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
    "0x8ce06e20ffeddac5fcd31fb891afdb3fbafaf4f82eefcda2bfd5cd7d757a037d"; // <------- change this
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);

  // query the receiver's result
  // --------------------------------------
  const receiverChain = "moonbaseAlpha";
  const receiverAddress = "0x98845062E9D4fF5e52C942Dc6876037A2448DA64"; // <------- change this

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
