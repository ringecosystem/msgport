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
    "0x2a85cf849fbf9ac4cf03cd0c26e8b0d31e6a5f8f81483fab73bdd3b4e770c8a7"; // <------- change this
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);

  // query the receiver's result
  // --------------------------------------
  const receiverChain = "fantomTestnet";
  const receiverAddress = "0x88076888542dDDb67b393cC83eEF9B1352B16F4a"; // <------- change this

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
