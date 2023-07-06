import { ethers } from "ethers";
import { getLine, LineType } from "./line";
import MsgportContract from "../artifacts/contracts/MessagePort.sol/MessagePort.json";
import { ILineSelectionStrategy } from "./interfaces/ILineSelectionStrategy";
import { lineTypeRegistry } from "./lineTypeRegistry";
import { IMsgport } from "./interfaces/IMsgport";
import { ChainId } from "./chain-ids";

export { LineType };

export async function getMsgport(
  provider: ethers.providers.Provider,
  msgportAddress: string
) {
  const msgport = new ethers.Contract(
    msgportAddress,
    MsgportContract.abi,
    provider
  );

  const result: IMsgport = {
    getLocalChainId: async () => {
      return await msgport.getLocalChainId();
    },

    getLocalLineAddress: async (
      toChainId: ChainId,
      selectLine: ILineSelectionStrategy
    ) => {
      const localLineAddresses = await msgport.getLocalLineAddressesByToChainId(
        toChainId
      );
      return await selectLine(localLineAddresses);
    },

    getLine: async (toChainId: ChainId, selectLine: ILineSelectionStrategy) => {
      const localLineAddress = await result.getLocalLineAddress(
        toChainId,
        selectLine
      );

      const lineType = lineTypeRegistry[localLineAddress];
      console.log(
        `localLineAddress: ${localLineAddress}, lineType: ${lineType}`
      );
      return await getLine(provider, localLineAddress, lineType);
    },

    getLocalLineAddressesByToChainId: async (toChainId: ChainId) => {
      console.log(`toChainId: ${toChainId}`);
      return await msgport.getLocalLineAddressesByToChainId(toChainId);
    },

    estimateFee: async (
      toChainId: ChainId,
      selectLine: ILineSelectionStrategy,
      messagePayload: string,
      feeMultiplier: number = 1.1,
      params = "0x"
    ) => {
      const localLine = await result.getLine(toChainId, selectLine);
      return await localLine.estimateFee(
        toChainId,
        messagePayload,
        feeMultiplier,
        params
      );
    },

    send: async (
      toChainId: ChainId,
      selectLine: ILineSelectionStrategy,
      toDappAddress: string,
      messagePayload: string,
      feeMultiplier: number = 1.1,
      params: string = "0x"
    ) => {
      // Get local line
      const localLine = await result.getLine(toChainId, selectLine);

      // Estimate fee through line
      const fee = await localLine.estimateFee(
        toChainId,
        messagePayload,
        feeMultiplier,
        params
      );
      const feeBN = ethers.BigNumber.from(`${fee}`);
      console.log(`cross-chain fee: ${fee / 1e18} UNITs.`);

      // Send message
      const tx = await msgport.send(
        localLine.address,
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
