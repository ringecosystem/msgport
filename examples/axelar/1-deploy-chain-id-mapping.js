const hre = require("hardhat");

// On fantomTestnet, chain id mapping contract deployed to: 0x413d48524021A95c463A97c50d57F097027D5E42
// On moonbaseAlpha, chain id mapping contract deployed to: 0x0DDB551bb20988b44640BAC6548FF508FD31d69e
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
