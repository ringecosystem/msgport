const { deployDock, setRemoteDock } = require("../helper");

async function main() {
  const pangolinMsgportAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F";
  const pangoroMsgportAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7";

  const pangolinEndpointAddress = "0xE8C0d3dF83a07892F912a71927F4740B8e0e04ab";
  const pangoroEndpointAddress = "0x23E31167E3D46D64327fdd6e783FE5391427B728";

  // PANGOLIN Dock
  const pangolinDockAddress = await deployDock(
    "pangolin",
    pangolinMsgportAddress,
    "DarwiniaS2sDock",
    [pangolinMsgportAddress, pangolinEndpointAddress]
  );

  // PANGORO Dock
  const pangoroDockAddress = await deployDock(
    "pangoro",
    pangoroMsgportAddress,
    "DarwiniaS2sDock",
    [pangoroMsgportAddress, pangoroEndpointAddress]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock(
    "pangolin",
    "DarwiniaS2sDock",
    pangolinDockAddress,
    pangoroDockAddress
  );
  await setRemoteDock(
    "pangoro",
    "DarwiniaS2sDock",
    pangoroDockAddress,
    pangolinDockAddress
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
