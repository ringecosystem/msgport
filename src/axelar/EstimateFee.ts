import { IEstimateFee } from "../interfaces/IEstimateFee";
import { ethers } from "ethers";
import {
  Environment,
  AxelarQueryAPI,
  EvmChain,
  GasToken,
} from "@axelar-network/axelarjs-sdk";
import AxelarLineContract from "../../artifacts/contracts/lines/AxelarLine.sol/AxelarLine.json";

const axelarNativeTokens: { [chainName: string]: string } = {};
axelarNativeTokens[EvmChain.ETHEREUM] = GasToken.ETH;
axelarNativeTokens[EvmChain.BNBCHAIN] = GasToken.BINANCE;
axelarNativeTokens[EvmChain.FANTOM] = GasToken.FTM;

async function buildEstimateFeeFunction(
  provider: ethers.providers.Provider,
  senderLineAddress: string,
  environment: Environment
) {
  const sdk = new AxelarQueryAPI({
    environment: environment,
  });

  // line
  const line = new ethers.Contract(
    senderLineAddress,
    AxelarLineContract.abi,
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
    const axelarSrcChainName = await line.chainIdDown(fromChainId);
    const axelarDstChainName = await line.chainIdDown(toChainId);
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
