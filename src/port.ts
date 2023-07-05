import { ethers } from "ethers";
import { getMessageDock, MessagingProviders } from "./dock";
import MsgportContract from "../artifacts/contracts/MessagePort.sol/MessagePort.json";
import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";
import { IMessagePort } from "./interfaces/IMessagePort";
import { ChainId } from "./chain-ids";

export { MessagingProviders };

export async function getMessagePort(
  provider: ethers.providers.Provider,
  msgportAddress: string
) {
  const msgport = new ethers.Contract(
    msgportAddress,
    MsgportContract.abi,
    provider
  );

  const result: IMessagePort = {
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
      return await getMessageDock(provider, localDockAddress);
    },

    getLocalDockAddressesByToChainId: async (toChainId: ChainId) => {
      console.log(`toChainId: ${toChainId}`);
      return await msgport.getLocalDockAddressesByToChainId(toChainId);
    },

    estimateFee: async (
      toChainId: ChainId,
      selectDock: IDockSelectionStrategy,
      messagePayload: string,
      feeMultiplier: number = 1.1,
      params = "0x"
    ) => {
      const localDock = await result.getDock(toChainId, selectDock);
      return await localDock.estimateFee(
        toChainId,
        messagePayload,
        feeMultiplier,
        params
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
        feeMultiplier,
        params
      );
      const feeBN = ethers.BigNumber.from(`${fee}`);
      console.log(`cross-chain fee: ${fee / 1e18} UNITs.`);

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
