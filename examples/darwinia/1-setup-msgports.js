const { deployLineRegistry, getChainId } = require("../helper");

async function main() {
  const senderChain = "goerli";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "pangolin";
  const receiverChainId = await getChainId(receiverChain);

  await deployLineRegistry(senderChain, senderChainId);
  await deployLineRegistry(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
