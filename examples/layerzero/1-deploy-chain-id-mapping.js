const hre = require("hardhat");

// On fantomTestnet, LayerZeroChainIdMapping contract deployed to: 0xAA87d749d6EF76CfBF64a2eEe5DA0921278Bf10C
// On moonbaseAlpha, LayerZeroChainIdMapping contract deployed to: 0x970A6C26dAf9db390d99290AF26109243585E2F6
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
