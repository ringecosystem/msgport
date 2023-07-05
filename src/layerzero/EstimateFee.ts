import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";
import LayerZeroDockContract from "../../artifacts/contracts/docks/LayerZeroDock.sol/LayerZeroDock.json";

async function buildEstimateFeeFunction(
  provider: ethers.providers.Provider,
  senderDockAddress: string
) {
  // dock
  const senderDock = new ethers.Contract(
    senderDockAddress,
    LayerZeroDockContract.abi,
    provider
  );
  const lzEndpointAddress =
    await senderDock.localLevelMessagingContractAddress();

  // endpoint
  const abi = [
    "function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee)",
  ];
  const endpoint = new ethers.Contract(lzEndpointAddress, abi, provider);

  // estimateFee function
  const estimateFee: IEstimateFee = async (
    fromChainId: number,
    fromDappAddress: string,
    toChainId: number,
    toDappAddress: string,
    messagePayload: string,
    feeMultiplier,
    params
  ) => {
    console.log(`fromChainId: ${fromChainId}, toChainId: ${toChainId}`);
    const lzSrcChainId = await senderDock.chainIdDown(fromChainId);
    const lzDstChainId = await senderDock.chainIdDown(toChainId);
    console.log(`lzSrcChainId: ${lzSrcChainId}, lzDstChainId: ${lzDstChainId}`);

    const payload = ethers.utils.defaultAbiCoder.encode(
      ["address", "address", "address", "bytes"],
      [senderDockAddress, fromDappAddress, toDappAddress, messagePayload]
    );

    console.log(`params: ${params}`);
    const result = await endpoint.estimateFees(
      lzDstChainId,
      senderDockAddress,
      payload,
      false,
      params
    );
    return result.nativeFee * feeMultiplier;
  };

  return estimateFee;
}

export { buildEstimateFeeFunction };
