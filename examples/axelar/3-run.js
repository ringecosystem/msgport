const hre = require("hardhat");
const { getMsgport } = require("../helper");
const {
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} = require("@axelar-network/axelarjs-sdk");

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

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  const fantomMsgportAddress = "0x0B4972B183C19B615658a928e6cB606D76B18dEd";

  // Deploy receiver
  hre.changeNetwork(receiverChain);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`${receiverChain} receiver: ${receiver.address}`);

  // Send message to receiver
  const estimateFee = buildEstimateFeeFunction(
    EvmChain.FANTOM,
    EvmChain.MOONBEAM,
    GasToken.FTM
  );
  const msgport = await getMsgport(senderChain, fantomMsgportAddress);
  msgport.send(receiver.address, "0x12345678", estimateFee);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
