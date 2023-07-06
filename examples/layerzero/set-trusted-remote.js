const hre = require("hardhat");

async function main() {
  const receiverChain = "polygonTestnet";
  const senderLineAddress = "0x06626341A9874F9223a3fC71e154C408c6BFb652";
  const receiverLineAddress = "0x13f5631A078Cf70C2D9D66978f81c851D12491d6";

  hre.changeNetwork(receiverChain);
  // attach the receiver's line contract
  let LayerZeroLine = await hre.ethers.getContractFactory("LayerZeroLine");
  const receiverLine = await LayerZeroLine.attach(receiverLineAddress);

  // set trusted remote
  // // Way 1:
  // let trustedRemote = hre.ethers.utils.solidityPack(
  //   ["address", "address"],
  //   [senderLineAddress, receiverLineAddress]
  // );
  // const tx = await receiverLine.setTrustedRemote(10102, trustedRemote, {
  //   gasLimit: 100000,
  // });

  // // OR, Way 2:
  // const tx = await receiverLine.setTrustedRemoteAddress(
  //   10102,
  //   senderLineAddress,
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
    [senderLineAddress, receiverLineAddress]
  );
  const result = await receiverLine.isTrustedRemote(
    10102, // sender layerzero chain id
    trustedRemote
  );
  console.log("isTrustedRemote: ", result);

  // const trustedRemote = await receiverLine.getTrustedRemoteAddress(10102);
  // console.log("trustedRemote: ", trustedRemote);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
