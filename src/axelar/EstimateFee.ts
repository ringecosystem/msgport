import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";
import {
  Environment,
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} from "@axelar-network/axelarjs-sdk";
import AxelarDockContract from "../../artifacts/contracts/docks/AxelarDock.sol/AxelarDock.json";

const axelarNativeTokens: { [chainName: string]: string } = {};
axelarNativeTokens[EvmChain.ETHEREUM] = GasToken.ETH;
axelarNativeTokens[EvmChain.BNBCHAIN] = GasToken.BINANCE;
axelarNativeTokens[EvmChain.FANTOM] = GasToken.FTM;

async function buildEstimateFeeFunction(
  provider: ethers.providers.Provider,
  senderDockAddress: string,
  environment: Environment
) {
  console.log(`buildEstimateFeeFunction: ${senderDockAddress}`);
  const sdk = new AxelarQueryAPI({
    environment: environment,
  });

  // dock
  const dock = new ethers.Contract(
    senderDockAddress,
    AxelarDockContract.abi,
    provider
  );

  const estimateFee: IEstimateFee = async (
    _fromChainId,
    _fromDappAddress,
    _toChainId,
    _toDappAddress,
    _messagePayload,
    feeMultiplier: number
  ) => {
    console.log(`estimateFee: ${_fromChainId} > ${_toChainId}`);
    const axelarSrcChainName = await dock.chainIdDown(_fromChainId);
    console.log(`axelarSrcChainName: ${axelarSrcChainName}`);
    const axelarDstChainName = await dock.chainIdDown(_toChainId);
    console.log(`axelarDstChainName: ${axelarDstChainName}`);

    const axelarSrcGasToken = axelarNativeTokens[axelarSrcChainName];

    return parseInt(
      (await sdk.estimateGasFee(
        axelarSrcChainName,
        axelarDstChainName,
        axelarSrcGasToken,
        100000,
        feeMultiplier,
        "2025000000"
      )) as string
    );
  };

  return estimateFee;
}

export { buildEstimateFeeFunction, Environment };
