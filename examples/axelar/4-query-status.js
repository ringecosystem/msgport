const {
  AxelarGMPRecoveryAPI,
  Environment,
} = require("@axelar-network/axelarjs-sdk");
const hre = require("hardhat");

async function main() {
  // query the cross chain message status
  const sdk = new AxelarGMPRecoveryAPI({
    environment: Environment.TESTNET,
  });
  const txHash =
    "0x2f59645568f4fb5f27600ca3d4003df4a1ed0d234a86fe20f5937987aa7f87a0";
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);

  // query the receiver's result
  const receiverChain = "moonbaseAlpha";
  const receiverAddress = "0x5068eb6ED371Bc9b1c76EaBB6B978CE12259F626";

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
