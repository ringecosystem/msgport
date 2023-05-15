import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";

async function buildEstimateFeeFunction(
  provider: ethers.providers.Provider,
  senderDockAddress: string
) {
  // dock
  const senderDock = new ethers.Contract(
    senderDockAddress,
    [
      "function lzEndpointAddress() public view returns (address)",
      "function lzTgtChainId() public view returns (uint16)",
    ],
    provider
  );
  const lzEndpointAddress = await senderDock.lzEndpointAddress();
  const lzTgtChainId = await senderDock.lzTgtChainId();

  // endpoint
  const abi = [
    "function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee)",
  ];
  const endpoint = new ethers.Contract(lzEndpointAddress, abi, provider);

  // estimateFee function
  const estimateFee: IEstimateFee = async (
    fromDappAddress,
    toDappAddress,
    messagePayload
  ) => {
    const payload = ethers.utils.defaultAbiCoder.encode(
      ["address", "address", "address", "bytes"],
      [senderDockAddress, fromDappAddress, toDappAddress, messagePayload]
    );
    const result = await endpoint.estimateFees(
      lzTgtChainId,
      senderDockAddress,
      payload,
      false,
      "0x"
    );
    return result.nativeFee;
  };

  return estimateFee;
}

export { buildEstimateFeeFunction };
