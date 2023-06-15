const hre = require("hardhat");
const { ChainId, ChainListId } = require("@layerzerolabs/lz-sdk");

function getChainIdsList() {
  const msgportChainids = [];
  const lzChainIds = [];
  Object.keys(ChainListId).forEach(function (chainKey) {
    if (isNaN(parseInt(chainKey)) && !chainKey.endsWith("_SANDBOX")) {
      const evmChainId = ChainListId[chainKey];
      const chainId = ChainId[chainKey]; // ChainId: chain key => chain id, and chain id => chain key
      if (evmChainId && chainId) {
        msgportChainids.push(evmChainId);
        lzChainIds.push(chainId);
      }
    }
  });

  return [msgportChainids, lzChainIds];
}

async function deployChainIdMappingContract(
  chainName,
  msgportChainids,
  lzChainIds
) {
  let LayerZeroChainIdMapping = await hre.ethers.getContractFactory(
    "LayerZeroChainIdMapping"
  );
  let layerZeroChainIdMapping = await LayerZeroChainIdMapping.deploy();
  await layerZeroChainIdMapping.deployed();
  await layerZeroChainIdMapping.setDownMapping(msgportChainids, lzChainIds);
  await layerZeroChainIdMapping.setUpMapping(lzChainIds, msgportChainids);
  console.log(
    `On ${chainName}, LayerZeroChainIdMapping contract deployed to: ${layerZeroChainIdMapping.address}`
  );
}

// On bnbChainTestnet, LayerZeroChainIdMapping contract deployed to: 0xA78aBD4CDAbCAf1A3Ae3F9105195E2c05810EE6E
// On polygonTestnet, LayerZeroChainIdMapping contract deployed to: 0xAFb5F12C5F379431253159fae464572999E78485
async function main() {
  const [msgportChainids, lzChainIds] = getChainIdsList();

  const senderChain = "bnbChainTestnet";
  const receiverChain = "polygonTestnet";

  hre.changeNetwork(senderChain);
  await deployChainIdMappingContract(senderChain, msgportChainids, lzChainIds);

  hre.changeNetwork(receiverChain);
  await deployChainIdMappingContract(
    receiverChain,
    msgportChainids,
    lzChainIds
  );
}

main();
