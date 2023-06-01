const hre = require("hardhat");

// On fantomTestnet, chain id mapping contract deployed to: 0x7e75c06A6a79d35Cb6D4bE96c2626FBBFe37d548
// On moonbaseAlpha, chain id mapping contract deployed to: 0xa1333f4749F5A808bbaCa735E95c4DB77573A14A
async function main() {
  ///////////////////////////////////////
  const senderChain = "fantomTestnet";
  hre.changeNetwork(senderChain);

  // deploy chain id mapping contract
  let AxelarTestnetChainIdMapping = await hre.ethers.getContractFactory(
    "AxelarTestnetChainIdMapping"
  );
  let axelarTestnetChainIdMapping = await AxelarTestnetChainIdMapping.deploy();
  await axelarTestnetChainIdMapping.deployed();

  console.log(
    `On ${senderChain}, chain id mapping contract deployed to: ${axelarTestnetChainIdMapping.address}`
  );

  ///////////////////////////////////////
  const receiverChain = "moonbaseAlpha";
  hre.changeNetwork(receiverChain);

  // deploy chain id mapping contract
  AxelarTestnetChainIdMapping = await hre.ethers.getContractFactory(
    "AxelarTestnetChainIdMapping"
  );
  axelarTestnetChainIdMapping = await AxelarTestnetChainIdMapping.deploy();
  await axelarTestnetChainIdMapping.deployed();

  console.log(
    `On ${receiverChain}, chain id mapping contract deployed to: ${axelarTestnetChainIdMapping.address}`
  );
}

main();
