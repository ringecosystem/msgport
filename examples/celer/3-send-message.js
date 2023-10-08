const { sendMessage } = require("../helper");
const { buildEstimateFeeFunction } = require("./celer-helper");

async function main() {
  const senderChain = "bnbChainTestnet";
  const receiverChain = "fantomTestnet";
  const senderLineRegistryAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573"; // <------- change this
  const estimateFee = buildEstimateFeeFunction(
    senderChain,
    "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA" // bnbChainTestnet message bus address
  );

  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  await sendMessage(
    senderChain,
    senderLineRegistryAddress,
    receiverChain,
    receiverAddress,
    "0x12345678",
    estimateFee
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
