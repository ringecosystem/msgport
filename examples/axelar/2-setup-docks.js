const { deployDock, setRemoteDock } = require("../helper");

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "polygonTestnet";

  const fantomMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";
  const fantomGateway = "0x97837985Ec0494E7b9C71f5D3f9250188477ae14";
  const fantomGasReceiver = "0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6";

  const polygonMsgportAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F";
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
  await setRemoteDock(senderChain, fantomDockAddress, polygonDockAddress);
  await setRemoteDock(receiverChain, polygonDockAddress, fantomDockAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
