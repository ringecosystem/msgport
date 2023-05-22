const hre = require("hardhat");

// On fantomTestnet, chain id mapping contract deployed to: 0xd9d42206AcC2d5c3860Cc3992F6A0E61E4f587F6
// On moonbaseAlpha, chain id mapping contract deployed to: 0x06B74269f991593eA2f42B23b0B87A3f1C5BA5C1
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
