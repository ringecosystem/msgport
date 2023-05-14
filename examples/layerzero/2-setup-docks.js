const { setupDocks } = require("../helper");
const { EvmChain } = require("@axelar-network/axelarjs-sdk");

// fantomTestnet LayerZeroDock: 0x567016a2c29bcc6f2c45bb476607972676dC4366
// baseGoerliTestnet LayerZeroDock: 0xAc100BE5bC97871Be400E31D29A5582C4853E598
async function main() {
  const senderChain = "fantomTestnet";
  const senderMsgportAddress = "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderDockName = "LayerZeroDock";
  const senderDockParams = [
    "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf", // sender lzEndpoint
    10112, // layerzero src chain id
    10160, // layerzero dst chain id
  ];

  const receiverChain = "baseGoerliTestnet";
  const receiverMsgportAddress = "0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94"; // <---- This is the receiver msgport address from 1-setup-msgports.js
  const receiverDockName = "LayerZeroDock";
  const receiverDockParams = [
    "0x6aB5Ae6822647046626e83ee6dB8187151E1d5ab", // receiver lzEndpoint
    10160, // layerzero src chain id
    10112, // layerzero dst chain id
  ];

  await setupDocks(
    senderChain,
    senderMsgportAddress,
    senderDockName,
    senderDockParams,
    receiverChain,
    receiverMsgportAddress,
    receiverDockName,
    receiverDockParams
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
