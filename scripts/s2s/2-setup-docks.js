const hre = require("hardhat");

// s2sPangolinDock: 0x719596B4e6F0865a2919647A1731a1435dFcda5f
// s2sPangoroDock: 0x046163b94B4c43D030f4661635A5abF5f3130261
async function main() {
  // PANGOLIN Dock
  hre.changeNetwork("pangolin");
  const S2sPangolinDock = await hre.ethers.getContractFactory(
    "DarwiniaS2sDock"
  );
  const s2sPangolinDock = await S2sPangolinDock.deploy(
    "0xE8C0d3dF83a07892F912a71927F4740B8e0e04ab"
  );
  await s2sPangolinDock.deployed();
  console.log(`s2sPangolinDock: ${s2sPangolinDock.address}`);

  // PANGORO Dock
  hre.changeNetwork("pangoro");
  const S2sPangoroDock = await hre.ethers.getContractFactory("DarwiniaS2sDock");
  const s2sPangoroDock = await S2sPangoroDock.deploy(
    "0x23E31167E3D46D64327fdd6e783FE5391427B728"
  );
  await s2sPangoroDock.deployed();
  console.log(`s2sPangoroDock: ${s2sPangoroDock.address}`);

  // CONNECT TO EACH OTHER
  await s2sPangoroDock.setRemoteDockAddress(s2sPangolinDock.address);
  hre.changeNetwork("pangolin");
  await s2sPangolinDock.setRemoteDockAddress(s2sPangoroDock.address);
  console.log("Done!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
