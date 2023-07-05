import { ethers } from "ethers";
import { getMessageDock, MessagingProviders } from "./dock";
import MsgportContract from "../artifacts/contracts/MessagePort.sol/MessagePort.json";
import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";
import { IMessagePort } from "./interfaces/IMessagePort";
import { ChainId } from "./chain-ids";

export { MessagingProviders };

export async function getMessagePort(
  client: ethers.providers.Provider | ethers.Signer,
  msgportAddress: string
) {
  let provider: ethers.providers.Provider;
  let signer: ethers.Signer;
  if (client instanceof ethers.Signer && client.provider) {
    provider = client.provider;
    signer = client;
  } else {
    provider = client as ethers.providers.Provider;
  }

  const msgportContract = new ethers.Contract(
    msgportAddress,
    MsgportContract.abi,
    provider
  );

  const result: IMessagePort = {
    getLocalChainId: async () => {
      return await msgportContract.getLocalChainId();
    },

    getLocalDockAddress: async (
      toChainId: ChainId,
      selectDock: IDockSelectionStrategy
    ) => {
      const localDockAddresses =
        await msgportContract.getLocalDockAddressesByToChainId(toChainId);
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
      return await msgportContract.getLocalDockAddressesByToChainId(toChainId);
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
      if (!signer) {
        throw new Error("signer is not set");
      }

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
      msgportContract.connect(signer);
      const tx = await msgportContract.send(
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
