const { setupDocks } = require("../helper");
const { EvmChain } = require("@axelar-network/axelarjs-sdk");

// fantomTestnet AxelarDock: 0x8CaC9B7D58068D549074a4EdaE2e9dBfbc9e0Bc3
// moonbaseAlpha AxelarDock: 0xdB2CDe10BE8517566B36A7561B2Cd0607A610836
async function main() {
  const senderChain = "fantomTestnet";
  const senderMsgportAddress = "0x067442c619147f73c2cCdeC5A80A3B0DBD5dff34"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderDockName = "AxelarDock";
  const senderDockParams = [
    "0x97837985Ec0494E7b9C71f5D3f9250188477ae14", // senderGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // senderGasReceiver
    EvmChain.FANTOM, // senderChain
    EvmChain.MOONBEAM, // receiverChain
  ];

  const receiverChain = "moonbaseAlpha";
  const receiverMsgportAddress = "0x6F9f7DCAc28F3382a17c11b53Bb11F20479754b1"; // <---- This is the receiver msgport address from 1-setup-msgports.js
  const receiverDockName = "AxelarDock";
  const receiverDockParams = [
    "0x5769D84DD62a6fD969856c75c7D321b84d455929", // receiverGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // receiverGasReceiver
    EvmChain.MOONBEAM, // senderChain
    EvmChain.FANTOM, // receiverChain
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
