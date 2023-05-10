const hre = require("hardhat");

async function deployMsgport(network) {
  hre.changeNetwork(network);
  const DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.deploy();
  await msgport.deployed();
  console.log(`${network} msgport: ${msgport.address}`);
}

// pangolin msgport: 0x3f1394274103cdc5ca842aeeC9118c512dea9A4F
// pangoro msgport: 0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7
async function main() {
  await deployMsgport("pangolin");
  await deployMsgport("pangoro");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
