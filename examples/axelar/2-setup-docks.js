const { deployDock, setRemoteDock } = require("../helper");
const { EvmChain } = require("@axelar-network/axelarjs-sdk");

// fantomTestnet AxelarDock: 0x14c3f58eA1054Fba834e801856F2985DEFe410f3
// moonbaseAlpha AxelarDock: 0x000dFde2A09e3b8C303B3174B5b4C91B22eE8bb2
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
