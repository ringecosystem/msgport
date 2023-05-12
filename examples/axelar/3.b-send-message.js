const { sendMessage } = require("../helper");
const {
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} = require("@axelar-network/axelarjs-sdk");

async function main() {
  const senderChain = "moonbaseAlpha";
  const receiverChain = "fantomTestnet";
  const senderMsgportAddress = "0x0E23B6e7009Ef520298ccFD8FC3F67E43223B77c"; // <------- change this
  const estimateFee = buildEstimateFeeFunction(
    EvmChain.MOONBEAM,
    EvmChain.FANTOM,
    GasToken.GLMR
  );

  await sendMessage(
    senderChain,
    senderMsgportAddress,
    receiverChain,
    "0x12345678",
    estimateFee
  );
}

function buildEstimateFeeFunction(
  axelarSrcChainName,
  axelarDstChainName,
  axelarSrcGasToken
) {
  const sdk = new AxelarQueryAPI({
    environment: "testnet",
  });
  return async (_fromDappAddress, _toDappAddress, _messagePayload) => {
    return await sdk.estimateGasFee(
      axelarSrcChainName,
      axelarDstChainName,
      axelarSrcGasToken,
      100000,
      1.1,
      "2025000000"
    );
  };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
