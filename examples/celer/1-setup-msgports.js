const hre = require("hardhat");

// bscMsgport: 0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94
// fantomMsgport: 0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94
async function main() {
  console.log("Setting up msgports...");

  hre.changeNetwork("bscTestnet");
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const bscMsgport = await DefaultMsgport.deploy();
  await bscMsgport.deployed();
  console.log(` bscMsgport: ${bscMsgport.address}`);

  hre.changeNetwork("fantomTestnet");
  DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const fantomMsgport = await DefaultMsgport.deploy();
  await fantomMsgport.deployed();
  console.log(` fantomMsgport: ${fantomMsgport.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
