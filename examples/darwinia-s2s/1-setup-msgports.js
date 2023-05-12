const { deployMsgport } = require("../helper");

async function main() {
  const senderChain = "pangolin";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "pangoro";
  const receiverChainId = await getChainId(receiverChain);

  await deployMsgport(senderChain, senderChainId);
  await deployMsgport(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
