const hre = require("hardhat");
const { ChainId, ChainListId } = require("@layerzerolabs/lz-sdk");

let findDuplicates = (arr) =>
  arr.filter((item, index) => arr.indexOf(item) !== index);

// get all
function getChainIdsList() {
  const msgportChainids = [];
  const lzChainIds = [];
  Object.keys(ChainListId).forEach(function (chainKey) {
    if (
      isNaN(parseInt(chainKey)) &&
      !chainKey.endsWith("_SANDBOX") &&
      !chainKey.startsWith("APTOS") &&
      chainKey != "GOERLI_MAINNET"
    ) {
      const evmChainId = ChainListId[chainKey];
      const chainId = ChainId[chainKey]; // ChainId: chain key => chain id, and chain id => chain key
      if (evmChainId && chainId) {
        // console.log(`${chainKey}: ${evmChainId} => ${chainId}`);
        msgportChainids.push(evmChainId);
        lzChainIds.push(chainId);
      }
    }
  });

  const dup = findDuplicates(msgportChainids);
  if (dup.length > 0) {
    throw "Duplicate msgportChainids: " + dup;
  }

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
  await (
    await layerZeroChainIdMapping.setDownMapping(msgportChainids, lzChainIds, {
      gasLimit: 1500000,
    })
  ).wait();
  await (
    await layerZeroChainIdMapping.setUpMapping(lzChainIds, msgportChainids, {
      gasLimit: 1500000,
    })
  ).wait();
  console.log(
    `On ${chainName}, LayerZeroChainIdMapping contract deployed to: ${layerZeroChainIdMapping.address}`
  );
}

// On bnbChainTestnet, LayerZeroChainIdMapping contract deployed to: 0x771E962b7Ecc66362BE3aA737BD0919744aa3C11
// On polygonTestnet, LayerZeroChainIdMapping contract deployed to: 0xd735Bb7a5c2f1Dc9E91dd3257A0E1FcB687d33E0
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
