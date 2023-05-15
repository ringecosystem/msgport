import { ethers } from "ethers";
import { IEstimateFee } from "./interfaces/IEstimateFee";
import { buildEstimateFeeFunction as buildEstimateFeeFunctionLayerZero } from "./layerzero/EstimateFee";

export async function getMsgport(
  provider: ethers.providers.Provider,
  msgportAddress: string
) {
  const msgport = new ethers.Contract(
    msgportAddress,
    [
      "function send(uint _toChainId, address _toDappAddress, bytes memory _messagePayload, uint256 _fee, bytes memory _params) external payable returns (uint256)",
      "function dockAddresses(uint256) public view returns (address)",
      "function localChainId() public view returns (uint256)",
    ],
    provider
  );

  return {
    getLocalChainId: async () => {
      return await msgport.localChainId();
    },

    getDockAddress: async (chainId: number) => {
      return await msgport.dockAddresses(chainId);
    },

    getDock: async (chainId: number) => {
      const dockAddress = await msgport.dockAddresses(chainId);
      const dock = new ethers.Contract(
        dockAddress,
        ["function getRemoteDockAddress() public view returns (address)"],
        provider
      );
      return {
        address: dockAddress,

        getRemoteDockAddress: async () => {
          return await dock.getRemoteDockAddress();
        },

        // TODO: add dock type
        estimateFee: async (messagePayload: string) => {
          const remoteDockAddress = await dock.getRemoteDockAddress();

          const estimateFee: IEstimateFee =
            await buildEstimateFeeFunctionLayerZero(provider, dockAddress);

          return await estimateFee(
            dockAddress,
            remoteDockAddress,
            messagePayload
          );
        },
      };
    },

    send: async (
      toChainId: number,
      fromDappAddress: string,
      toDappAddress: string,
      messagePayload: string,
      estimateFee: IEstimateFee,
      params = "0x"
    ) => {
      // Estimate fee
      const fee = await estimateFee(
        fromDappAddress,
        toDappAddress,
        messagePayload
      );
      console.log(`cross-chain fee: ${fee} wei.`);

      // Send message
      const tx = await msgport.send(
        toChainId,
        toDappAddress,
        messagePayload,
        fee,
        params,
        {
          value: ethers.BigNumber.from(fee),
        }
      );

      console.log(
        `message "${messagePayload}" sent to ${toDappAddress} through ${await provider.getNetwork()}'s msgport ${msgportAddress}`
      );

      console.log(`tx hash: ${(await tx.wait()).transactionHash}`);
    },
  };
}
