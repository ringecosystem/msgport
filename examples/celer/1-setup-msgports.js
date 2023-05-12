const { deployMsgport, getChainId } = require("../helper");

// bnbChainTestnet msgport: 0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573
// fantomTestnet msgport: 0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573
async function main() {
  const senderChain = "bnbChainTestnet";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "fantomTestnet";
  const receiverChainId = await getChainId(receiverChain);

  await deployMsgport(senderChain, senderChainId);
  await deployMsgport(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
