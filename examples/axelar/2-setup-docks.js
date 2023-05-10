const { deployDock, setRemoteDock } = require("../helper");

// fantomTestnet AxelarDock: 0x8d2318F02e619726EC12061eF253B7bD82D0e5E8
// polygonTestnet AxelarDock: 0x6c3af2A2DB9c8CE7F698FC866eaC6E5ed7C24D9f
async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "polygonTestnet";

  const fantomMsgportAddress = "0x0B4972B183C19B615658a928e6cB606D76B18dEd";
  const fantomGateway = "0x97837985Ec0494E7b9C71f5D3f9250188477ae14";
  const fantomGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  const polygonMsgportAddress = "0x0E23B6e7009Ef520298ccFD8FC3F67E43223B77c";
  const polygonGateway = "0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B";
  const polygonGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  // fantom Dock
  const fantomDockAddress = await deployDock(
    senderChain,
    fantomMsgportAddress,
    "AxelarDock",
    [fantomMsgportAddress, fantomGateway, fantomGasReceiver]
  );

  // polygon Dock
  const polygonDockAddress = await deployDock(
    receiverChain,
    polygonMsgportAddress,
    "AxelarDock",
    [polygonMsgportAddress, polygonGateway, polygonGasReceiver]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock(
    senderChain,
    "AxelarDock",
    fantomDockAddress,
    polygonDockAddress
  );
  await setRemoteDock(
    receiverChain,
    "AxelarDock",
    polygonDockAddress,
    fantomDockAddress
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
