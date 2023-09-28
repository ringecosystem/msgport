import { ethers } from "ethers";
import { getLine, LineType } from "./line";
import LineRegistryContract from "../artifacts/contracts/LineRegistry.sol/LineRegistry.json";
import { ILineSelectionStrategy } from "./interfaces/ILineSelectionStrategy";
import { lineTypeRegistry } from "./lineTypeRegistry";
import { ILineRegistry } from "./interfaces/ILineRegistry";
import { ChainId } from "./chain-ids";

export { LineType };

export async function getLineRegistry(
  provider: ethers.providers.Provider,
  lineRegistryAddress: string
) {
  const lineRegistry = new ethers.Contract(
    lineRegistryAddress,
    LineRegistryContract.abi,
    provider
  );

  const result: ILineRegistry = {
    getLocalChainId: async () => {
      return await lineRegistry.getLocalChainId();
    },

    getLocalLineAddress: async (
      toChainId: ChainId,
      selectLine: ILineSelectionStrategy
    ) => {
      const localLineAddresses = await lineRegistry.getLocalLineAddressesByToChainId(
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
      return await lineRegistry.getLocalLineAddressesByToChainId(toChainId);
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
      let fee = await localLine.estimateFee(
        toChainId,
        messagePayload,
        feeMultiplier,
        params
      );
      fee = Math.ceil(fee);
      console.log(`estimateFee: ${fee}`)
      const feeBN = ethers.BigNumber.from(`${fee}`);
      console.log(`cross-chain fee: ${fee / 1e18} UNITs.`);

      // Send message
      const tx = await lineRegistry.send(
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
        `message "${messagePayload}" has been sent to ${toDappAddress} through lineRegistry ${lineRegistryAddress}`
      );

      return tx;
    },
  };

  return result;
}
