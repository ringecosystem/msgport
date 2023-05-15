const { deployMsgport, getChainId } = require("../helper");

// fantomTestnet msgport: 0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599
// baseGoerliTestnet msgport: 0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94
async function main() {
  // const senderChain = "fantomTestnet";
  // const senderChainId = await getChainId(senderChain);
  // await deployMsgport(senderChain, senderChainId);

  const receiverChain = "baseGoerliTestnet";
  const receiverChainId = await getChainId(receiverChain);
  await deployMsgport(receiverChain, receiverChainId);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
