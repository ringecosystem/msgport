const { getChainId } = require("../helper");
const { EvmChain, GasToken } = require("@axelar-network/axelarjs-sdk");
const hre = require("hardhat");
const { getMsgport, DockType } = require("../dist/index");

// moonbaseAlpha receiver: 0xAFb5F12C5F379431253159fae464572999E78485
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";
  const senderMsgportAddress = "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"; // <------- change this
  const estimateFee = buildEstimateFeeFunction(
    EvmChain.FANTOM,
    EvmChain.MOONBEAM,
    GasToken.FTM
  );

  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  // Send message to receiver
  const msgport = await getMsgport(
    hre.ethers.getDefaultProvider(),
    senderMsgportAddress
  );
  const receiverChainId = await getChainId(receiverChain);
  const fromDappAddress = (await hre.ethers.getSigner()).address;
  await msgport.send(
    receiverChainId,
    fromDappAddress,
    receiverAddress,
    "0x12345678",
    estimateFee
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
