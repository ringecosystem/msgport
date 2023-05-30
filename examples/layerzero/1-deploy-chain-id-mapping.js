const hre = require("hardhat");

// On fantomTestnet, LayerZeroChainIdMapping contract deployed to: 0x1D612F014BC3a1e7980dD0aE12D0d3d240864e83
// On moonbaseAlpha, LayerZeroChainIdMapping contract deployed to: 0xFe89354a5ee07F66D9fB0DB2aDa67c1F09eF286c
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
