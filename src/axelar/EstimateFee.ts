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
    fromChainId,
    _fromDappAddress,
    toChainId,
    _toDappAddress,
    _messagePayload,
    feeMultiplier,
    params
  ) => {
    console.log(`fromChainId: ${fromChainId}, toChainId: ${toChainId}`);
    const axelarSrcChainName = await dock.chainIdDown(fromChainId);
    const axelarDstChainName = await dock.chainIdDown(toChainId);
    console.log(
      `axelarSrcChainName: ${axelarSrcChainName}, axelarDstChainName: ${axelarDstChainName}`
    );

    const gasLimit = ethers.utils.defaultAbiCoder.decode(
      ["uint256"],
      params
    )[0];
    console.log(`gasLimit: ${gasLimit}`);

    const axelarSrcGasToken = axelarNativeTokens[axelarSrcChainName];

    return parseInt(
      (await sdk.estimateGasFee(
        axelarSrcChainName,
        axelarDstChainName,
        axelarSrcGasToken,
        gasLimit,
        feeMultiplier,
        "2025000000"
      )) as string
    );
  };

  return estimateFee;
}

export { buildEstimateFeeFunction, Environment };
