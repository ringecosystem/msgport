const { deployMsgport, getChainId } = require("../helper");

// fantomTestnet msgport: 0x067442c619147f73c2cCdeC5A80A3B0DBD5dff34
// moonbaseAlpha msgport: 0x6F9f7DCAc28F3382a17c11b53Bb11F20479754b1
async function main() {
  const senderChain = "fantomTestnet";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "moonbaseAlpha";
  const receiverChainId = await getChainId(receiverChain);

  await deployMsgport(senderChain, senderChainId);
  await deployMsgport(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
