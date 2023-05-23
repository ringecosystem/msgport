const hre = require("hardhat");

// On fantomTestnet, chain id mapping contract deployed to: 0xF72C04C06513Af687CFaDbFcEe486E2ac156158D
// On moonbaseAlpha, chain id mapping contract deployed to: 0x9286b7e01bA7d1157252c5cB1c1066E00F88f5Db
async function main() {
  ///////////////////////////////////////
  const senderChain = "fantomTestnet";
  hre.changeNetwork(senderChain);

  // deploy chain id mapping contract
  let LayerZeroChainIdMapping = await hre.ethers.getContractFactory(
    "LayerZeroChainIdMapping"
  );
  let layerZeroChainIdMapping = await LayerZeroChainIdMapping.deploy();
  await layerZeroChainIdMapping.deployed();

  console.log(
    `On ${senderChain}, LayerZeroChainIdMapping contract deployed to: ${layerZeroChainIdMapping.address}`
  );

  ///////////////////////////////////////
  const receiverChain = "moonbaseAlpha";
  hre.changeNetwork(receiverChain);

  // deploy chain id mapping contract
  LayerZeroChainIdMapping = await hre.ethers.getContractFactory(
    "LayerZeroChainIdMapping"
  );
  layerZeroChainIdMapping = await LayerZeroChainIdMapping.deploy();
  await layerZeroChainIdMapping.deployed();

  console.log(
    `On ${receiverChain}, LayerZeroChainIdMapping contract deployed to: ${layerZeroChainIdMapping.address}`
  );
}

main();
