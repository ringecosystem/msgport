const hre = require("hardhat");
const { sendMessage, deployReceiver } = require("../helper");

async function main() {
  const senderChain = "pangoro";
  const receiverChain = "moonbaseAlpha";
  const senderMsgportAddress = "0x1D612F014BC3a1e7980dD0aE12D0d3d240864e83"; // <------- change this
  const estimateFee = async (_fromDappAddress, _toDappAddress, _messagePayload) => 0;

  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  const params = hre.ethers.utils.defaultAbiCoder.encode(
    ["uint64", "uint64", "uint128"], // refTime, proofSize fungible
    ["5000000000", "65536", "5000000000000000000"]
  );
  await sendMessage(
    senderChain,
    senderMsgportAddress,
    receiverChain,
    receiverAddress,
    "0x12345678",
    estimateFee,
    params
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
