// import { ethers } from "ethers";
import { ChainId } from "./chain-ids";
import { getLineRegistry } from "./lineRegistry";
import { getLine, LineType } from "./line";
import { axelar } from "./axelar/index";
import { layerzero } from "./layerzero/index";
import { createDefaultLineSelectionStrategy } from "./DefaultLineSelectionStrategy";
import { ILineSelectionStrategy } from "./interfaces/ILineSelectionStrategy";

export { getLineRegistry, ChainId };
export { getLine, LineType };
export { ILineSelectionStrategy, createDefaultLineSelectionStrategy };
export { axelar, layerzero };

// async function main(): Promise<void> {
//   const provider = new ethers.providers.JsonRpcProvider(
//     "https://bsc-testnet.publicnode.com"
//   );

//   const lineRegistry = await getLineRegistry(
//     provider,
//     "0xeF1c60AB9B902c13585411dC929005B98Ca44541"
//   );

//   const lineSelection: ILineSelectionStrategy = async (
//     lineAddresses: string[]
//   ) => "0x017D8C573a54cc43e2D23EC8Fa756D92777c3217";

//   // const line = await lineRegistry.getLine(
//   //   ChainId.POLYGON_MUMBAI, // target chain id
//   //   lineSelection
//   // );
//   // console.log(`line: ${line}`);

//   const lineAddresses = await lineRegistry.getLocalLineAddressesByToChainId(
//     ChainId.BNBCHAIN_TESTNET
//   );
//   console.log(`lineAddresses: ${lineAddresses}`);

//   // const fee = await line.estimateFee(ChainId.MOONBASE_ALPHA, "0x12345678");
//   // console.log(`cross-chain fee: ${fee} wei.`);

//   // toChainId: number,
//   //     selectLine: ILineSelectionStrategy,
//   //     toDappAddress: string,
//   //     messagePayload: string,
//   //     params: string = "0x",
//   //     feeMultiplier: number = 1.1

//   // const tx = await lineRegistry.send(
//   //   lineSelection,
//   //   1287, // target chain id
// }

// import IChainIdMapping from "../artifacts/contracts/interfaces/IChainIdMapping.sol/IChainIdMapping.json";
// async function main(): Promise<void> {
//   const chainIdMappingAddress = "0x26a4fAE216359De954a927dEbaB339C09Dbf7e8e";

//   const provider = new ethers.providers.JsonRpcProvider(
//     "https://polygon-testnet.public.blastapi.io"
//   );

//   const mapping = new ethers.Contract(
//     chainIdMappingAddress,
//     IChainIdMapping.abi,
//     provider
//   );

//   const lineRegistryChainId = await mapping.up("0x2776"); // 10102
//   console.log(lineRegistryChainId);
//   const lzChainId = await mapping.down(97);
//   console.log(lzChainId);
// }

// main();
