const { deployLineRegistry } = require("../helper");

async function main() {
  const senderChain = "pangolin";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "pangoro";
  const receiverChainId = await getChainId(receiverChain);

  await deployLineRegistry(senderChain, senderChainId);
  await deployLineRegistry(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
