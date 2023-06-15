import { ethers } from "ethers";
import { ChainId } from "./chain-ids";
import { getMsgport } from "./msgport";
import { getDock, DockType } from "./dock";
import { axelar } from "./axelar/index";
import { layerzero } from "./layerzero/index";
import { createDefaultDockSelectionStrategy } from "./DefaultDockSelectionStrategy";
import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";

export { getMsgport, ChainId };
export { getDock, DockType };
export { IDockSelectionStrategy, createDefaultDockSelectionStrategy };
export { axelar, layerzero };

async function main(): Promise<void> {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://bsc-testnet.publicnode.com"
  );

  const msgport = await getMsgport(
    provider,
    "0xeF1c60AB9B902c13585411dC929005B98Ca44541"
  );

  const dockSelection: IDockSelectionStrategy = async (
    dockAddresses: string[]
  ) => "0x017D8C573a54cc43e2D23EC8Fa756D92777c3217";

  // const dock = await msgport.getDock(
  //   ChainId.POLYGON_MUMBAI, // target chain id
  //   dockSelection
  // );
  // console.log(`dock: ${dock}`);

  const dockAddresses = await msgport.getLocalDockAddressesByToChainId(
    ChainId.BNBCHAIN_TESTNET
  );
  console.log(`dockAddresses: ${dockAddresses}`);

  // const fee = await dock.estimateFee(ChainId.MOONBASE_ALPHA, "0x12345678");
  // console.log(`cross-chain fee: ${fee} wei.`);

  // toChainId: number,
  //     selectDock: IDockSelectionStrategy,
  //     toDappAddress: string,
  //     messagePayload: string,
  //     params: string = "0x",
  //     feeMultiplier: number = 1.1

  // const tx = await msgport.send(
  //   dockSelection,
  //   1287, // target chain id
}

// import IChainIdMapping from "../artifacts/contracts/interfaces/IChainIdMapping.sol/IChainIdMapping.json";
// async function main(): Promise<void> {
//   const chainIdMappingAddress = "0x7e75c06A6a79d35Cb6D4bE96c2626FBBFe37d548";

//   const provider = new ethers.providers.JsonRpcProvider(
//     "https://rpc.testnet.fantom.network"
//   );

//   const mapping = new ethers.Contract(
//     chainIdMappingAddress,
//     IChainIdMapping.abi,
//     provider
//   );

//   const chainId = await mapping.down(1287);
//   console.log(chainId);
// }

// main();
