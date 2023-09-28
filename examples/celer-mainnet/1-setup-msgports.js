const { deployLineRegistry, getChainId } = require("../helper");

// fantom lineRegistry: 0x7bB47867d8BA255c79e6f5BaCAC6e3194D05C273
// bnbChain lineRegistry: 0x770497281303Cdb2e0252B82AdEEA1d61896dD43
async function main() {
  const senderChain = "fantom";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "bnbChain";
  const receiverChainId = await getChainId(receiverChain);

  await deployLineRegistry(senderChain, senderChainId);
  await deployLineRegistry(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
