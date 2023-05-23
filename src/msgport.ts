import { ethers } from "ethers";
import { getDock, DockType } from "./dock";
import DefaultMsgportContract from "../artifacts/contracts/DefaultMsgport.sol/DefaultMsgport.json";
import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";
import { dockTypeRegistry } from "./dockTypeRegistry";
import { IMsgport } from "./interfaces/IMsgport";
import { ChainId } from "./chain-ids";

export { DockType };

export async function getMsgport(
  provider: ethers.providers.Provider,
  msgportAddress: string
) {
  const msgport = new ethers.Contract(
    msgportAddress,
    DefaultMsgportContract.abi,
    provider
  );

  const result: IMsgport = {
    getLocalChainId: async () => {
      return await msgport.getLocalChainId();
    },

    getLocalDockAddress: async (
      toChainId: ChainId,
      selectDock: IDockSelectionStrategy
    ) => {
      const localDockAddresses = await msgport.getLocalDockAddressesByToChainId(
        toChainId
      );
      return await selectDock(localDockAddresses);
    },

    getDock: async (toChainId: ChainId, selectDock: IDockSelectionStrategy) => {
      const localDockAddress = await result.getLocalDockAddress(
        toChainId,
        selectDock
      );

      console.log(`localDockAddress: ${localDockAddress}`);
      const dockType = dockTypeRegistry[localDockAddress];
      console.log(`dockType: ${dockType}`);
      return await getDock(provider, localDockAddress, dockType);
    },

    getLocalDockAddressesByToChainId: async (toChainId: ChainId) => {
      return await msgport.localDockAddressesByToChainId(toChainId);
    },

    estimateFee: async (
      toChainId: ChainId,
      selectDock: IDockSelectionStrategy,
      messagePayload: string,
      feeMultiplier: number = 1.0
    ) => {
      const localDock = await result.getDock(toChainId, selectDock);
      return await localDock.estimateFee(
        toChainId,
        messagePayload,
        feeMultiplier
      );
    },

    send: async (
      toChainId: ChainId,
      selectDock: IDockSelectionStrategy,
      toDappAddress: string,
      messagePayload: string,
      feeMultiplier: number = 1.1,
      params: string = "0x"
    ) => {
      // Get local dock
      const localDock = await result.getDock(toChainId, selectDock);

      // Estimate fee through dock
      const fee = await localDock.estimateFee(
        toChainId,
        messagePayload,
        feeMultiplier
      );
      const feeBN = ethers.BigNumber.from(`${fee}`);
      console.log(`cross-chain fee: ${fee / 1e18} UNITS.`);

      // Send message
      const tx = await msgport.send(
        localDock.address,
        toChainId,
        toDappAddress,
        messagePayload,
        params,
        {
          value: feeBN,
        }
      );

      console.log(
        `message "${messagePayload}" has been sent to ${toDappAddress} through msgport ${msgportAddress}`
      );

      return tx;
    },
  };

  return result;
}
