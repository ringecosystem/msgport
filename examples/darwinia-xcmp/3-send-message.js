const hre = require("hardhat");
const { getMsgport, deployReceiver } = require("../helper");

async function main() {
  const senderChain = "pangolin";
  const receiverChain = "rocstar";

  const srcMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";

  // Deploy receiver
  await deployReceiver(receiverChain);

  // Send message to receiver
  const msgport = await getMsgport(senderChain, srcMsgportAddress);
  msgport.send(
    receiver.address,
    "0x12345678",
    async (_, _, _) => 0,
    hre.ethers.utils.defaultAbiCoder.encode(
      ["uint64", "uint64", "uint128"], // refTime, proofSize fungible
      ["5000000000", "65536", "5000000000000000000"]
    )
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
