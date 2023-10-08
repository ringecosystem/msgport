const { setupLines } = require("../helper");

async function main() {
  const senderChain = "bnbChainTestnet";
  const senderLineRegistryAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573"; // <---- This is the sender lineRegistry address from 1-setup-lineRegistrys.js
  const senderLineName = "CelerLine";
  const senderLineParams = [
    "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA", // senderMessageBus
    97, // senderChainId
    4002, // receiverChainId
  ];

  const receiverChain = "fantomTestnet";
  const receiverLineRegistryAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573"; // <---- This is the receiver lineRegistry address from 1-setup-lineRegistrys.js
  const receiverLineName = "CelerLine";
  const receiverLineParams = [
    "0xb92d6933A024bcca9A21669a480C236Cbc973110", // receiverMessageBus
    4002, // senderChainId
    97, // receiverChainId
  ];

  await setupLines(
    senderChain,
    senderLineRegistryAddress,
    senderLineName,
    senderLineParams,
    receiverChain,
    receiverLineRegistryAddress,
    receiverLineName,
    receiverLineParams
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
