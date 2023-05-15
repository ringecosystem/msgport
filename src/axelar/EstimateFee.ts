import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";
import {
  Environment,
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} from "@axelar-network/axelarjs-sdk";

const axelarNativeTokens: { [chainName: string]: string } = {};
axelarNativeTokens[EvmChain.ETHEREUM] = GasToken.ETH;
axelarNativeTokens[EvmChain.BNBCHAIN] = GasToken.BINANCE;
axelarNativeTokens[EvmChain.FANTOM] = GasToken.FTM;

async function buildEstimateFeeFunction(
  provider: ethers.providers.Provider,
  senderDockAddress: string,
  environment: Environment
) {
  const sdk = new AxelarQueryAPI({
    environment: environment,
  });

  // dock
  const dock = new ethers.Contract(
    senderDockAddress,
    [
      "function sourceChain() public view returns (string)",
      "function destinationChain() public view returns (string)",
    ],
    provider
  );
  const axelarSrcChainName = await dock.sourceChain();
  const axelarDstChainName = await dock.destinationChain();
  const axelarSrcGasToken = axelarNativeTokens[axelarSrcChainName];

  const estimateFee: IEstimateFee = async (
    _fromDappAddress,
    _toDappAddress,
    _messagePayload
  ) => {
    return parseInt(
      (await sdk.estimateGasFee(
        axelarSrcChainName,
        axelarDstChainName,
        axelarSrcGasToken,
        100000,
        1.1,
        "2025000000"
      )) as string
    );
  };

  return estimateFee;
}

export { buildEstimateFeeFunction, Environment };
