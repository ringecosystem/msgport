const { deployDock, setRemoteDock } = require("../helper");
const { EvmChain } = require("@axelar-network/axelarjs-sdk");

// fantomTestnet AxelarDock: 0xE80266BDfF9CD848309a2A5580f7695fa496c40d
// moonbaseAlpha AxelarDock: 0x8669BC1898283A5fBa18BBe1dD86D96d6B6E6aEe
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  const fantomMsgportAddress = "0x0B4972B183C19B615658a928e6cB606D76B18dEd";
  const fantomGateway = "0x97837985Ec0494E7b9C71f5D3f9250188477ae14";
  const fantomGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  const moonbaseMsgportAddress = "0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94";
  const moonbaseGateway = "0x5769D84DD62a6fD969856c75c7D321b84d455929";
  const moonbaseGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  // fantom Dock
  const fantomDockAddress = await deployDock(
    senderChain,
    fantomMsgportAddress,
    "AxelarDock",
    [
      fantomMsgportAddress,
      fantomGateway,
      fantomGasReceiver,
      EvmChain.FANTOM,
      EvmChain.MOONBEAM,
    ]
  );

  // moonbase Dock
  const moonbaseDockAddress = await deployDock(
    receiverChain,
    moonbaseMsgportAddress,
    "AxelarDock",
    [
      moonbaseMsgportAddress,
      moonbaseGateway,
      moonbaseGasReceiver,
      EvmChain.MOONBEAM,
      EvmChain.FANTOM,
    ]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock(
    senderChain,
    "AxelarDock",
    fantomDockAddress,
    moonbaseDockAddress
  );
  await setRemoteDock(
    receiverChain,
    "AxelarDock",
    moonbaseDockAddress,
    fantomDockAddress
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
