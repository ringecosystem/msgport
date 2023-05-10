const hre = require("hardhat");

async function deployDock(network, msgportAddress, dockName, dockArgs) {
  hre.changeNetwork(network);
  let Dock = await hre.ethers.getContractFactory(dockName);
  let dock = await Dock.deploy(...dockArgs);
  await dock.deployed();
  console.log(`${network} ${dockName} dock: ${dock.address}`);

  // Add it to the msgport
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.attach(msgportAddress);
  await (await msgport.setDock(dock.address)).wait();
  console.log(
    ` ${network} dock ${dock.address} set on msgport ${msgportAddress}`
  );

  return dock.address;
}

async function setRemoteDock(network, dockAddress, remoteDockAddress) {
  hre.changeNetwork(network);
  let Dock = await hre.ethers.getContractFactory("DarwiniaS2sDock");
  let dock = await Dock.attach(dockAddress);
  await (await dock.setRemoteDockAddress(remoteDockAddress)).wait();
  console.log(
    `${network} dock ${dockAddress} set remote dock ${remoteDockAddress}`
  );
}

// pangolin DarwiniaS2sDock dock: 0x91E5FEF790928D89d4d6e10478eFC82eC949B0A7
// pangoro DarwiniaS2sDock dock: 0x8205b173786DC663d328D1CD9AdBCCb3877aBC6E
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
  await setRemoteDock("pangolin", pangolinDockAddress, pangoroDockAddress);
  await setRemoteDock("pangoro", pangoroDockAddress, pangolinDockAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
