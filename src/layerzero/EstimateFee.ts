import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";
import LayerZeroLineContract from "../../artifacts/contracts/lines/LayerZeroLine.sol/LayerZeroLine.json";
import LayerZeroChainIdMappingContract from "../../artifacts/contracts/chain-id-mappings/LayerZeroChainIdMapping.sol/LayerZeroChainIdMapping.json"

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
  // chainIdMapping
  const chainIdMappingAddress = senderLine.chainIdMappingAddress();
  const chainIdMapping = new ethers.Contract(
    chainIdMappingAddress,
    LayerZeroChainIdMappingContract.abi,
    provider
  )
  const lzEndpointAddress = await senderLine.localMessagingContractAddress();

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
    const lzSrcChainId = await chainIdMapping.down(fromChainId);
    const lzDstChainId = await chainIdMapping.down(toChainId);
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
