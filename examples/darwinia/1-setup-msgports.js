const { deployMsgport, getChainId } = require("../helper");

async function main() {
  const senderChain = "goerli";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "pangolin";
  const receiverChainId = await getChainId(receiverChain);

  await deployMsgport(senderChain, senderChainId);
  await deployMsgport(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
