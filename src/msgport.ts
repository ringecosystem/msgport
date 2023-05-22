import { ethers } from "ethers";
import { getDock, DockType } from "./dock";
import DefaultMsgportContract from "../artifacts/contracts/DefaultMsgport.sol/DefaultMsgport.json";
import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";
import { dockTypeRegistry } from "./dockTypeRegistry";
import { IMsgport } from "./interfaces/IMsgport";

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
      toChainId: number,
      selectDock: IDockSelectionStrategy
    ) => {
      const localDockAddresses = await msgport.localDockAddressesByToChainId(
        toChainId
      );
      return await selectDock(localDockAddresses);
    },

    getDock: async (toChainId: number, selectDock: IDockSelectionStrategy) => {
      const localDockAddress = await result.getLocalDockAddress(
        toChainId,
        selectDock
      );

      console.log(`Local dock address: ${localDockAddress}`);
      const dockType = dockTypeRegistry[localDockAddress];
      return await getDock(provider, localDockAddress, dockType);
    },

    getLocalDockAddressesByToChainId: async (toChainId: number) => {
      return await msgport.localDockAddressesByToChainId(toChainId);
    },

    send: async (
      toChainId: number,
      toDappAddress: string,
      messagePayload: string,
      dockType: DockType,
      params = "0x"
    ) => {
      // Estimate fee through dock
      const dockAddresses = await msgport.dockAddresses(toChainId);
      const dock = await getDock(provider, dockAddresses[0], dockType);
      const fee = await dock.estimateFee(messagePayload);
      const feeBN = ethers.BigNumber.from(`${fee}`);
      console.log(`cross-chain fee: ${fee / 1e18} units.`);

      // Send message
      const tx = await msgport.send(
        toChainId,
        toDappAddress,
        messagePayload,
        feeBN,
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
