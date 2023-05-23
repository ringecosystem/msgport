// import { ethers } from "ethers";
import { ChainId } from "./chain-ids";
import { getMsgport, DockType } from "./msgport";
import { axelar } from "./axelar/index";
import { layerzero } from "./layerzero/index";
import { createDefaultDockSelectionStrategy } from "./DefaultDockSelectionStrategy";
import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";

export { getMsgport, ChainId, DockType };
export { IDockSelectionStrategy, createDefaultDockSelectionStrategy };
export { axelar, layerzero };

/*
async function main(): Promise<void> {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.testnet.fantom.network"
  );

  const msgport = await getMsgport(
    provider,
    "0x308f61D8a88f010146C4Ec15897ABc1EFc57c80a"
  );

  const dockSelection: IDockSelectionStrategy =
    createDefaultDockSelectionStrategy(provider);

  const dock = await msgport.getDock(
    1287, // target chain id
    dockSelection
  );

  const fee = await dock.estimateFee(ChainId.MOONBASE_ALPHA, "0x12345678");
  console.log(`cross-chain fee: ${fee} wei.`);

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

main();
*/
