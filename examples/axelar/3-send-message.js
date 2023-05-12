const { getMsgport, deployReceiver, getChainId } = require("../helper");
const hre = require("hardhat");
const {
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} = require("@axelar-network/axelarjs-sdk");

// moonbaseAlpha receiver: 0xAFb5F12C5F379431253159fae464572999E78485
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";
  const receiverChainId = await getChainId(receiverChain);

  const senderMsgportAddress = "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"; // <------- change this

  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  // Send message to receiver
  const estimateFee = buildEstimateFeeFunction(
    EvmChain.FANTOM,
    EvmChain.MOONBEAM,
    GasToken.FTM
  );
  hre.changeNetwork(senderChain);
  const msgport = await getMsgport(senderChain, senderMsgportAddress);
  msgport.send(receiverChainId, receiverAddress, "0x12345678", estimateFee);
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
