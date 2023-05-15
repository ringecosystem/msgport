const { getMsgport, DockType } = require("../dist/index");
const { ethers } = require("ethers");

async function main() {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.testnet.fantom.network"
  );

  const msgport = await getMsgport(
    provider,
    "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"
  );

  const messagePayload = "0x12345678";

  await layerZero_fantomTestnet_to_baseTestnet(msgport, messagePayload);
  await axelar_fantomTestnet_to_moonbaseAlpha(msgport, messagePayload);
}

async function layerZero_fantomTestnet_to_baseTestnet(msgport, messagePayload) {
  const dock = await msgport.getDock(
    84531, // Base testnet chain ID
    DockType.LayerZero // or, add dock type to contract
  );

  const fee = await dock.estimateFee(messagePayload);
  console.log(
    `LayerZero: Fantom testnet => Base testnet cross-chain fee: ${fee} wei.`,
    "\n--------------------"
  );
}

async function axelar_fantomTestnet_to_moonbaseAlpha(msgport, messagePayload) {
  const dock = await msgport.getDock(
    1287, // moonbase alpha chain ID
    DockType.AxelarTestnet
  );

  const fee = await dock.estimateFee(messagePayload);
  console.log(
    `Axelar: Fantom testnet => moonbase alpha cross-chain fee: ${fee} wei.`,
    "\n--------------------"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
