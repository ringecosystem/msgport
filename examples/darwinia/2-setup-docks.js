const { deployDock, setRemoteDock } = require("../helper");

async function main() {
  const senderChain = "goerli";
  const receiverChain = "pangolin";

  const goerliMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";
  const pangolinMsgportAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F";

  const goerliOutboundLaneAddress =
    "0x9B5010d562dDF969fbb85bC72222919B699b5F54";
  const goerliInboundLaneAddress = "0x0F6e081B1054c59559Cf162e82503F3f560cA4AF";
  const goerliFeeMarketAddress = "0x6c73B30a48Bb633DC353ed406384F73dcACcA5C3";

  const pangolinOutboundLaneAddress =
    "0xAbd165DE531d26c229F9E43747a8d683eAD54C6c";
  const pangolinInboundLaneAddress =
    "0xB59a893f5115c1Ca737E36365302550074C32023";
  const pangolinFeeMarketAddress = "0x4DBdC9767F03dd078B5a1FC05053Dd0C071Cc005";

  // goerli Dock
  const goerliDockAddress = await deployDock(
    senderChain,
    goerliMsgportAddress,
    "DarwiniaDock",
    [
      goerliMsgportAddress,
      goerliOutboundLaneAddress,
      goerliInboundLaneAddress,
      goerliFeeMarketAddress,
    ]
  );

  // pangolin Dock
  const pangolinDockAddress = await deployDock(
    receiverChain,
    pangolinMsgportAddress,
    "DarwiniaDock",
    [
      pangolinMsgportAddress,
      pangolinOutboundLaneAddress,
      pangolinInboundLaneAddress,
      pangolinFeeMarketAddress,
    ]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock(
    senderChain,
    "DarwiniaDock",
    goerliDockAddress,
    pangolinDockAddress
  );
  await setRemoteDock(
    receiverChain,
    "DarwiniaDock",
    pangolinDockAddress,
    goerliDockAddress
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
