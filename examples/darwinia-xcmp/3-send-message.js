const hre = require("hardhat");
const { sendMessage } = require("../helper");

async function main() {
  const senderChain = "pangolin";
  const receiverChain = "rocstar";
  const senderMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7"; // <------- change this
  const estimateFee = async (_, _, _) => 0;

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
