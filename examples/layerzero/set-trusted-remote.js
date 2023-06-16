const hre = require("hardhat");

async function main() {
  const receiverChain = "polygonTestnet";
  const senderDockAddress = "0x06626341A9874F9223a3fC71e154C408c6BFb652";
  const receiverDockAddress = "0x13f5631A078Cf70C2D9D66978f81c851D12491d6";

  hre.changeNetwork(receiverChain);
  // attach the receiver's dock contract
  let LayerZeroDock = await hre.ethers.getContractFactory("LayerZeroDock");
  const receiverDock = await LayerZeroDock.attach(receiverDockAddress);

  // set trusted remote
  // // Way 1:
  // let trustedRemote = hre.ethers.utils.solidityPack(
  //   ["address", "address"],
  //   [senderDockAddress, receiverDockAddress]
  // );
  // const tx = await receiverDock.setTrustedRemote(10102, trustedRemote, {
  //   gasLimit: 100000,
  // });

  // // OR, Way 2:
  // const tx = await receiverDock.setTrustedRemoteAddress(
  //   10102,
  //   senderDockAddress,
  //   {
  //     gasLimit: 100000,
  //   }
  // );
  // console.log(
  //   `Trusted Remote set: https://mumbai.polygonscan.com/tx/${
  //     (await tx.wait()).transactionHash
  //   }`
  // );

  // check result
  let trustedRemote = hre.ethers.utils.solidityPack(
    ["address", "address"],
    [senderDockAddress, receiverDockAddress]
  );
  const result = await receiverDock.isTrustedRemote(
    10102, // sender layerzero chain id
    trustedRemote
  );
  console.log("isTrustedRemote: ", result);

  // const trustedRemote = await receiverDock.getTrustedRemoteAddress(10102);
  // console.log("trustedRemote: ", trustedRemote);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
