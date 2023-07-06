import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";
import LayerZeroLineContract from "../../artifacts/contracts/lines/LayerZeroLine.sol/LayerZeroLine.json";

async function buildEstimateFeeFunction(
  provider: ethers.providers.Provider,
  senderLineAddress: string
) {
  // line
  const senderLine = new ethers.Contract(
    senderLineAddress,
    LayerZeroLineContract.abi,
    provider
  );
  const lzEndpointAddress = await senderLine.lzEndpointAddress();

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
    const lzSrcChainId = await senderLine.chainIdDown(fromChainId);
    const lzDstChainId = await senderLine.chainIdDown(toChainId);
    console.log(`lzSrcChainId: ${lzSrcChainId}, lzDstChainId: ${lzDstChainId}`);

    const payload = ethers.utils.defaultAbiCoder.encode(
      ["address", "address", "address", "bytes"],
      [senderLineAddress, fromDappAddress, toDappAddress, messagePayload]
    );

    console.log(`params: ${params}`);
    const result = await endpoint.estimateFees(
      lzDstChainId,
      senderLineAddress,
      payload,
      false,
      params
    );
    return result.nativeFee * feeMultiplier;
  };

  return estimateFee;
}

export { buildEstimateFeeFunction };
