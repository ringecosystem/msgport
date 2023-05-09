const hre = require("hardhat");

// goerliDock: 0xcF7dC57e24cF3d2a31fC52f7ed9538959870Cf2A
// pangolinDock: 0xEF9F4db2e4ABACcB425Cb208672492f41ec667Db
async function main() {
  const goerliMsgportAddress = process.argv[2];
  const pangolinMsgportAddress = process.argv[3];

  console.log("Setting up docks...");

  //////////////////////////
  // GOERLI Dock
  //////////////////////////
  hre.changeNetwork("goerli");
  let GoerliDock = await hre.ethers.getContractFactory("DarwiniaDock");
  let goerliDock = await GoerliDock.deploy(
    goerliMsgportAddress,
    "0x9B5010d562dDF969fbb85bC72222919B699b5F54", // outbound lane
    "0x0F6e081B1054c59559Cf162e82503F3f560cA4AF", // inbound lane
    "0x6c73B30a48Bb633DC353ed406384F73dcACcA5C3"
  );
  await goerliDock.deployed();
  console.log(` goerliDock: ${goerliDock.address}`);

  // Add it to the msgport
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const goerliMsgport = await DefaultMsgport.attach(goerliMsgportAddress);
  await (await goerliMsgport.setDock(goerliDock.address)).wait();

  //////////////////////////
  // PANGOLIN Dock
  //////////////////////////
  hre.changeNetwork("pangolin");
  const DarwiniaDock = await hre.ethers.getContractFactory("DarwiniaDock");
  const pangolinDock = await DarwiniaDock.deploy(
    pangolinMsgportAddress,
    "0xAbd165DE531d26c229F9E43747a8d683eAD54C6c",
    "0xB59a893f5115c1Ca737E36365302550074C32023",
    "0x4DBdC9767F03dd078B5a1FC05053Dd0C071Cc005"
  );
  await pangolinDock.deployed();
  console.log(` pangolinDock: ${pangolinDock.address}`);

  // Add it to the msgport
  DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const pangolinMsgport = await DefaultMsgport.attach(pangolinMsgportAddress);
  await (await pangolinMsgport.setDock(pangolinDock.address)).wait();

  //////////////////////////
  // CONNECT THE MSGPORTS TO EACH OTHER
  //////////////////////////
  console.log("Connecting docks...");
  await pangolinDock.setRemoteDockAddress(goerliDock.address);
  console.log(" Connected pangolinDock to goerliDock...");

  hre.changeNetwork("goerli");
  await goerliDock.setRemoteDockAddress(pangolinDock.address);
  console.log(" Connected goerliDock to pangolinDock...");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
