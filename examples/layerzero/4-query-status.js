const hre = require("hardhat");

async function main() {
  const receiverChain = "polygonTestnet";
  const receiverAddress = "0xe13084f8fF65B755E37d95F49edbD49ca26feE13";

  hre.changeNetwork(receiverChain);
  // attach the receiver's line contract
  let ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiverDapp = await ExampleReceiverDapp.attach(receiverAddress);

  const fromDappAddress = await receiverDapp.fromDappAddress();
  console.log("fromDappAddress: ", fromDappAddress);
  const message = await receiverDapp.message();
  console.log("message: ", message);
  const nonce = await receiverDapp.nonce();
  console.log("nonce: ", nonce);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
