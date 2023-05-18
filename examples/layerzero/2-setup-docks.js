const { setupDocks } = require("../helper");

// fantomTestnet LayerZeroDock: 0x26a4fAE216359De954a927dEbaB339C09Dbf7e8e
// baseGoerliTestnet LayerZeroDock: 0xeE61384eA18F0C4771FB6f85300D7a9F988a948d

// fantomTestnet LayerZeroDock: 0xdDE5a388B660520d23F418d3f3F7e38EF0CA30C6
// ··fantomTestnet LayerZeroDock 0xdDE5a388B660520d23F418d3f3F7e38EF0CA30C6 set on msgport 0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599
// baseGoerliTestnet LayerZeroDock: 0x5068eb6ED371Bc9b1c76EaBB6B978CE12259F626
// ··baseGoerliTestnet LayerZeroDock 0x5068eb6ED371Bc9b1c76EaBB6B978CE12259F626 set on msgport 0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94
// fantomTestnet LayerZeroDock 0xdDE5a388B660520d23F418d3f3F7e38EF0CA30C6 set remote dock 0x5068eb6ED371Bc9b1c76EaBB6B978CE12259F626
// baseGoerliTestnet LayerZeroDock 0x5068eb6ED371Bc9b1c76EaBB6B978CE12259F626 set remote dock 0xdDE5a388B660520d23F418d3f3F7e38EF0CA30C6
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
    receiverDockParams,
    200000
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
