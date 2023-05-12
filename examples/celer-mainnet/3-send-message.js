const { sendMessage } = require("../helper");
const { buildEstimateFeeFunction } = require("../celer/celer-helper");

async function main() {
  const senderChain = "fantom";
  const receiverChain = "bnbChain";
  const senderMsgportAddress = "0x7bB47867d8BA255c79e6f5BaCAC6e3194D05C273"; // <------- change this
  const estimateFee = buildEstimateFeeFunction(
    senderChain,
    "0xFF4E183a0Ceb4Fa98E63BbF8077B929c8E5A2bA4" // bnbChainTestnet message bus address
  );

  await sendMessage(
    senderChain,
    senderMsgportAddress,
    receiverChain,
    "0x12345678",
    estimateFee
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
