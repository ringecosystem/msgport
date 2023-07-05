import { ethers } from "ethers";
import IChainIdMapping from "../../artifacts/contracts/interfaces/IChainIdMapping.sol/IChainIdMapping.json";
import LayerZeroDock from "../../artifacts/contracts/docks/LayerZeroDock.sol/LayerZeroDock.json";

async function main(): Promise<void> {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://endpoints.omniatech.io/v1/bsc/testnet/public"
  );

  ////////////////////////////////
  const mappingContract = new ethers.Contract(
    "0x771E962b7Ecc66362BE3aA737BD0919744aa3C11",
    IChainIdMapping.abi,
    provider
  );

  const lzChainId = await mappingContract.down(97);
  console.log(`lzChainId: ${lzChainId}`);
  const chainId = await mappingContract.up("0x2776");
  console.log(`chainId: ${chainId}`);

  ////////////////////////////////
  const dockContract = new ethers.Contract(
    "0x3d5F09572DdD5f52A70c32d0EC6F67b4d18e62bB",
    LayerZeroDock.abi,
    provider
  );

  const lzChainId2 = await dockContract.chainIdDown(97);
  console.log(`lzChainId2: ${lzChainId2}`);
  const chainId2 = await dockContract.chainIdUp(10102);
  console.log(`chainId2: ${chainId2}`);
}
main();
