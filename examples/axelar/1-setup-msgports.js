const { deployMsgport, getChainId } = require("../helper");

// fantomTestnet msgport: 0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599
// moonbaseAlpha msgport: 0x0E23B6e7009Ef520298ccFD8FC3F67E43223B77c
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
