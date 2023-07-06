const { getMsgport, ChainId } = require("../dist/src/index");
const { ethers } = require("ethers");

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.testnet.fantom.network"
  );

  const msgport = await getMsgport(
    provider,
    "0x308f61D8a88f010146C4Ec15897ABc1EFc57c80a"
  );

  const messagePayload = "0x12345678";

  await layerZero_fantomTestnet_to_moonbaseAlpha(msgport, messagePayload);
  await axelar_fantomTestnet_to_moonbaseAlpha(msgport, messagePayload);
}

async function layerZero_fantomTestnet_to_moonbaseAlpha(
  msgport,
  messagePayload
) {
  const lineSelection = async (_) =>
    "0xbf8d576f4204774f1EAdF9C4480133EE486E649C";

  const fee = await msgport.estimateFee(
    ChainId.MOONBASE_ALPHA,
    lineSelection,
    messagePayload
  );

  console.log(
    `> LayerZero: Fantom testnet => moonbase alpha cross-chain fee: ${
      fee / 1e18
    } FTMs.`,
    "\n--------------------"
  );
}

async function axelar_fantomTestnet_to_moonbaseAlpha(msgport, messagePayload) {
  const lineSelection = async (_) =>
    "0xE447B04655a1EaA0fE35C2aD126667CDa458b4aD";

  const fee = await msgport.estimateFee(
    ChainId.MOONBASE_ALPHA,
    lineSelection,
    messagePayload
  );

  console.log(
    `> Axelar: Fantom testnet => moonbase alpha cross-chain fee: ${
      fee / 1e18
    } FTMs.`,
    "\n--------------------"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
