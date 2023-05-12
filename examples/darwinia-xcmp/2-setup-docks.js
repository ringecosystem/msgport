const { deployDock, setRemoteDock } = require("../helper");

async function main() {
  const senderChain = "pangolin";
  const receiverChain = "rocstar";

  const srcMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";
  const tgtMsgportAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F";

  const srcParaId = "0xe520";
  const srcPolkadotXcmSendCallIndex = "0x2100";
  const tgtParaId = "0x591f";
  const tgtPolkadotXcmSendCallIndex = "0x2100";

  // src Dock
  const srcDockAddress = await deployDock(
    senderChain,
    srcMsgportAddress,
    "DarwiniaXcmpDock",
    [srcMsgportAddress, srcParaId, tgtParaId, srcPolkadotXcmSendCallIndex]
  );

  // tgt Dock
  const tgtDockAddress = await deployDock(
    receiverChain,
    tgtMsgportAddress,
    "DarwiniaXcmpDock",
    [tgtMsgportAddress, tgtParaId, srcParaId, tgtPolkadotXcmSendCallIndex]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock(
    senderChain,
    "DarwiniaXcmpDock",
    srcDockAddress,
    tgtDockAddress
  );
  await setRemoteDock(
    receiverChain,
    "DarwiniaXcmpDock",
    tgtDockAddress,
    srcDockAddress
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
