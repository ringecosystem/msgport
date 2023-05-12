const { setupDocks } = require("../helper");
const { EvmChain } = require("@axelar-network/axelarjs-sdk");

// fantomTestnet AxelarDock: 0xD461E0fFC07672416d9Ec21d1929b20D931885A6
// moonbaseAlpha AxelarDock: 0x6c3af2A2DB9c8CE7F698FC866eaC6E5ed7C24D9f
async function main() {
  const senderChain = "fantomTestnet";
  const senderMsgportAddress = "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderDockName = "AxelarDock";
  const senderDockParams = [
    "0x97837985Ec0494E7b9C71f5D3f9250188477ae14", // senderGateway
    "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6", // senderGasReceiver
    EvmChain.FANTOM, // senderChain
    EvmChain.MOONBEAM, // receiverChain
  ];

  const receiverChain = "moonbaseAlpha";
  const receiverMsgportAddress = "0x0E23B6e7009Ef520298ccFD8FC3F67E43223B77c"; // <---- This is the receiver msgport address from 1-setup-msgports.js
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
