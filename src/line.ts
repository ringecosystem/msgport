import { ethers } from "ethers";
import { IEstimateFee } from "./interfaces/IEstimateFee";
import { layerzero } from "./layerzero/index";
import { axelar } from "./axelar/index";
import BaseMessageLineContract from "../artifacts/contracts/lines/base/BaseMessageLine.sol/BaseMessageLine.json";
import { ILine } from "./interfaces/ILine";

enum LineType {
  Axelar = 0,
  AxelarTestnet = 1,
  Celer = 2,
  Darwinia = 3,
  DarwiniaS2S = 4,
  DarwiniaXcmp = 5,
  LayerZero = 6,
}

async function getLine(
  provider: ethers.providers.Provider,
  lineAddress: string,
  lineType: LineType
) {
  const line = new ethers.Contract(
    lineAddress,
    BaseMessageLineContract.abi,
    provider
  );

  let estimateFee: IEstimateFee = await buildEstimateFunction(
    provider,
    lineType,
    lineAddress
  );

  const result: ILine = {
    address: lineAddress,

    getLocalChainId: async () => {
      return await line.getLocalChainId();
    },

    getOutboundLane: async (remoteChainId: number) => {
      const outboundLane = await line.outboundLanes(remoteChainId);
      return {
        fromChainId: await result.getLocalChainId(),
        fromLineAddress: lineAddress,
        toChainId: outboundLane["toChainId"],
        toLineAddress: outboundLane["toLineAddress"],
        nonce: outboundLane["nonce"],
      };
    },

    getRemoteLineAddress: async (remoteChainId: number) => {
      const lane = await line.outboundLanes(remoteChainId);
      return lane["toLineAddress"];
    },

    estimateFee: async (
      remoteChainId: number,
      messagePayload: string,
      feeMultiplier: number,
      params
    ) => {
      const remoteLineAddress = await result.getRemoteLineAddress(
        remoteChainId
      );
      console.log(`remoteLineAddress: ${remoteLineAddress}`);

      return await estimateFee(
        await line.getLocalChainId(),
        lineAddress,
        remoteChainId,
        remoteLineAddress,
        messagePayload,
        feeMultiplier,
        params
      );
    },
  };

  return result;
}

async function buildEstimateFunction(
  provider: ethers.providers.Provider,
  lineType: LineType,
  lineAddress: string
) {
  let estimateFee: IEstimateFee;
  if (lineType == LineType.LayerZero) {
    estimateFee = await layerzero.buildEstimateFeeFunction(
      provider,
      lineAddress
    );
  } else if (lineType == LineType.Axelar) {
    estimateFee = await axelar.buildEstimateFeeFunction(
      provider,
      lineAddress,
      axelar.Environment.MAINNET
    );
  } else if (lineType == LineType.AxelarTestnet) {
    estimateFee = await axelar.buildEstimateFeeFunction(
      provider,
      lineAddress,
      axelar.Environment.TESTNET
    );
  } else {
    throw new Error("Unsupported line type");
  }
  return estimateFee;
}

export { getLine, LineType };
