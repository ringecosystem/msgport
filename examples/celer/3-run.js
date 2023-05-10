const hre = require("hardhat");
const { getMsgport } = require("../helper");

async function main() {
  // Deploy receiver
  hre.changeNetwork("fantomTestnet");
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`receiver: ${receiver.address}`);

  // Send message to receiver
  const bscMsgportAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573";
  const msgport = await getMsgport("bscTestnet", bscMsgportAddress);
  msgport.send(receiver.address, "0x12345678");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
