import { ethers } from "ethers";
import { getDock, DockType } from "./dock";

export { DockType };

export async function getMsgport(
  provider: ethers.providers.Provider,
  msgportAddress: string
) {
  const msgport = new ethers.Contract(
    msgportAddress,
    [
      "function send(uint _toChainId, address _toDappAddress, bytes memory _messagePayload, uint256 _fee, bytes memory _params) external payable returns (uint256)",
      "function getDockAddress(uint256 _toChainId) public view returns (address)",
      "function localChainId() public view returns (uint256)",
    ],
    provider
  );

  return {
    getLocalChainId: async () => {
      return await msgport.localChainId();
    },

    getDockAddress: async (chainId: number) => {
      return await msgport.getDockAddress(chainId);
    },

    getDock: async (chainId: number, dockType: DockType) => {
      const dockAddress = await msgport.getDockAddress(chainId);
      console.log(`dock address: ${dockAddress}`);
      return await getDock(provider, dockAddress, dockType);
    },

    send: async (
      toChainId: number,
      toDappAddress: string,
      messagePayload: string,
      dockType: DockType,
      params = "0x"
    ) => {
      // Estimate fee through dock
      const dockAddress = await msgport.getDockAddress(toChainId);
      const dock = await getDock(provider, dockAddress, dockType);
      const fee = await dock.estimateFee("messagePayload");
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
        `message "${messagePayload}" sent to ${toDappAddress} through msgport ${msgportAddress}`
      );

      console.log(`tx hash: ${(await tx.wait()).transactionHash}`);
    },
  };
}
