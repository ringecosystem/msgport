const { deployDock, setRemoteDock, getChainId } = require("../helper");
const { EvmChain } = require("@axelar-network/axelarjs-sdk");

// fantomTestnet AxelarDock: 0xD461E0fFC07672416d9Ec21d1929b20D931885A6
// moonbaseAlpha AxelarDock: 0x6c3af2A2DB9c8CE7F698FC866eaC6E5ed7C24D9f
async function main() {
  // Prepare sender and receiver info
  const senderChain = "fantomTestnet";
  const senderChainId = await getChainId(senderChain);

  const receiverChain = "moonbaseAlpha";
  const receiverChainId = await getChainId(receiverChain);

  const senderMsgportAddress = "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"; // <---- This is the sender msgport address from 1-setup-msgports.js
  const senderGateway = "0x97837985Ec0494E7b9C71f5D3f9250188477ae14";
  const senderGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  const receiverMsgportAddress = "0x0E23B6e7009Ef520298ccFD8FC3F67E43223B77c"; // <---- This is the receiver msgport address from 1-setup-msgports.js
  const receiverGateway = "0x5769D84DD62a6fD969856c75c7D321b84d455929";
  const receiverGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  // Deploy sender Dock
  const senderDockAddress = await deployDock(
    senderChain,
    senderMsgportAddress,
    receiverChainId,
    "AxelarDock",
    [senderGateway, senderGasReceiver, EvmChain.FANTOM, EvmChain.MOONBEAM]
  );

  // Deploy receiver Dock
  const receiverDockAddress = await deployDock(
    receiverChain,
    receiverMsgportAddress,
    senderChainId,
    "AxelarDock",
    [receiverGateway, receiverGasReceiver, EvmChain.MOONBEAM, EvmChain.FANTOM]
  );

  // Configure remote Dock
  await setRemoteDock(
    senderChain,
    "AxelarDock",
    senderDockAddress,
    receiverDockAddress
  );
  await setRemoteDock(
    receiverChain,
    "AxelarDock",
    receiverDockAddress,
    senderDockAddress
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
