const { deployLineRegistry, getChainId } = require("../helper");

// bnbChainTestnet lineRegistry: 0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573
// fantomTestnet lineRegistry: 0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573
async function main() {
  const senderChain = "bnbChainTestnet";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "fantomTestnet";
  const receiverChainId = await getChainId(receiverChain);

  await deployLineRegistry(senderChain, senderChainId);
  await deployLineRegistry(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
