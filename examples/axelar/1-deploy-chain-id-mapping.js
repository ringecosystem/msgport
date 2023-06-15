const hre = require("hardhat");

// On fantomTestnet, chain id mapping contract deployed to: 0x8D7767AEB493d13F8207CCfFf5B9420314567Bc2
// On moonbaseAlpha, chain id mapping contract deployed to: 0xF732E38B74d8BcB94bB3024A85567152dE3335F6
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
