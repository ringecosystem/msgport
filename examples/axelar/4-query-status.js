const {
  AxelarGMPRecoveryAPI,
  Environment,
} = require("@axelar-network/axelarjs-sdk");
const hre = require("hardhat");
const { getLine, LineType } = require("../../dist/src/index");

// Examples:
// https://testnet.axelarscan.io/gmp/0x121079ed2211ede771d0ee532054306c21832f1d45d1e805d3eec4bda70d3923
// https://testnet.axelarscan.io/gmp/0x0c0643e340f080c22d97150737af9fe051f3008630bbf75e5d4f113ac0d5b6ff
async function main() {
  // query the nonce
  // --------------------------------------
  const senderChain = "fantomTestnet";
  hre.changeNetwork(senderChain);
  const line = await getLine(
    await hre.ethers.provider,
    "0x807a3e011DF1785c538Ac6F65252bf740678Ff99", // <------- change this, sender line address,
    LineType.AxelarTestnet
  );
  const outboundLane = await line.getOutboundLane(1287);
  console.log("outbound lane:");
  for (const [key, value] of Object.entries(outboundLane)) {
    console.log(`  ${key}: ${value}`);
  }

  // query the cross chain message status
  // --------------------------------------
  const sdk = new AxelarGMPRecoveryAPI({
    environment: Environment.TESTNET,
  });
  const txHash =
    "0x2b9cdad2f666521f3ea41fe26d8797f1a88a3a8eae273c303ef6baf7b895903a"; // <------- change this
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);

  // query the receiver's result
  // --------------------------------------
  const receiverChain = "moonbaseAlpha";
  const receiverAddress = "0xd735Bb7a5c2f1Dc9E91dd3257A0E1FcB687d33E0"; // <------- change this

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
