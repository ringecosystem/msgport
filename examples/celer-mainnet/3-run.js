const hre = require("hardhat");
const { getMsgport } = require("../helper");

async function main() {
  const senderChain = "fantom";
  const receiverChain = "bnbChain";

  const fantomMsgportAddress = "0x7bB47867d8BA255c79e6f5BaCAC6e3194D05C273";

  // Deploy receiver
  hre.changeNetwork(receiverChain);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`${receiverChain} receiver: ${receiver.address}`);

  // Send message to receiver
  const msgport = await getMsgport(senderChain, fantomMsgportAddress);
  msgport.send(receiver.address, "0x12345678");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
