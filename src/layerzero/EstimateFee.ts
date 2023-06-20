import { IEstimateFee } from "../interfaces/IEstimateFee";
import { PublicClient, getContract } from "viem";
import { encodeAbiParameters, parseAbiParameters } from "viem";
import LayerZeroDockContract from "../../artifacts/contracts/docks/LayerZeroDock.sol/LayerZeroDock.json";

async function buildEstimateFeeFunction(
  provider: PublicClient,
  senderDockAddress: string
) {
  // dock
  const senderDock = getContract({
    address: senderDockAddress as `0x${string}`,
    abi: LayerZeroDockContract.abi,
    publicClient: provider,
  });
  const lzEndpointAddress = await senderDock.read.lzEndpointAddress();

  // endpoint
  const abi = [
    "function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee)",
  ];
  const endpoint = getContract({
    address: lzEndpointAddress as `0x${string}`,
    abi: abi,
    publicClient: provider,
  });

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
    const lzSrcChainId = await senderDock.read.chainIdDown([fromChainId]);
    const lzDstChainId = await senderDock.read.chainIdDown([toChainId]);
    console.log(`lzSrcChainId: ${lzSrcChainId}, lzDstChainId: ${lzDstChainId}`);

    const payload = encodeAbiParameters(
      parseAbiParameters("address, address, address, bytes"),
      [
        senderDockAddress as `0x${string}`,
        fromDappAddress as `0x${string}`,
        toDappAddress as `0x${string}`,
        messagePayload as `0x${string}`,
      ]
    );

    console.log(`params: ${params}`);
    const result = await endpoint.read.estimateFees([
      lzDstChainId,
      senderDockAddress,
      payload,
      false,
      params,
    ]);
    return (
      (result as { nativeFee: number; zroFee: number }).nativeFee *
      feeMultiplier
    );
  };

  return estimateFee;
}

export { buildEstimateFeeFunction };
