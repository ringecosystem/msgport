const hre = require("hardhat");

// bscDock: 0x3173c3e608125226A0069ba75f8feb73b221974a
// fantomDock: 0xAc100BE5bC97871Be400E31D29A5582C4853E598
async function main() {
  const bscMsgportAddress = process.argv[2];
  const fantomMsgportAddress = process.argv[3];

  // console.log("Setting up docks...");

  // //////////////////////////
  // // BSC Dock
  // //////////////////////////
  // hre.changeNetwork("bscTestnet");
  // let BscDock = await hre.ethers.getContractFactory(
  //   "TestnetCelerBscFantomDock"
  // );
  // let bscDock = await BscDock.deploy(
  //   bscMsgportAddress,
  //   "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA" // celer bsc testnet message bus address
  // );
  // await bscDock.deployed();
  // console.log(` bscDock: ${bscDock.address}`);

  // // Add it to the msgport
  // let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  // const bscMsgport = await DefaultMsgport.attach(bscMsgportAddress);
  // await (await bscMsgport.setDock(bscDock.address)).wait();
  // console.log(
  //   ` bsc dock ${bscDock.address} set on bsc msgport ${bscMsgportAddress}`
  // );

  // //////////////////////////
  // // FANTOM Dock
  // //////////////////////////
  // hre.changeNetwork("fantomTestnet");
  // const FantomDock = await hre.ethers.getContractFactory(
  //   "TestnetCelerBscFantomDock"
  // );
  // const fantomDock = await FantomDock.deploy(
  //   fantomMsgportAddress,
  //   "0xb92d6933A024bcca9A21669a480C236Cbc973110" // celer fantom testnet message bus address
  // );
  // await fantomDock.deployed();
  // console.log(` fantomDock: ${fantomDock.address}`);

  // // Add it to the msgport
  // DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  // const fantomMsgport = await DefaultMsgport.attach(fantomMsgportAddress);
  // await (await fantomMsgport.setDock(fantomDock.address)).wait();
  // console.log(
  //   ` fantom dock ${fantomDock.address} set on fantom msgport ${fantomMsgportAddress}`
  // );

  //////////////////////////
  // CONNECT THE MSGPORTS TO EACH OTHER
  //////////////////////////
  const bscDockAddress = "0x3173c3e608125226A0069ba75f8feb73b221974a";
  const fantomDockAddress = "0xAc100BE5bC97871Be400E31D29A5582C4853E598";

  console.log("Connecting docks...");

  //
  hre.changeNetwork("fantomTestnet");
  const FantomDock = await hre.ethers.getContractFactory(
    "TestnetCelerBscFantomDock"
  );
  const fantomDock = await FantomDock.attach(fantomDockAddress);

  await fantomDock.setRemoteDockAddress(bscDockAddress);
  console.log(" Connected fantomDock to bscDock...");

  //
  hre.changeNetwork("bscTestnet");
  const BscDock = await hre.ethers.getContractFactory(
    "TestnetCelerBscFantomDock"
  );
  const bscDock = await BscDock.attach(bscDockAddress);
  await bscDock.setRemoteDockAddress(fantomDockAddress);
  console.log(" Connected bscDock to fantomDock...");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
