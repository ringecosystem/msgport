import { ethers } from "ethers";
import { IEstimateFee } from "./interfaces/IEstimateFee";
import { layerzero } from "./layerzero/index";
import { axelar } from "./axelar/index";
import BaseMessageDockContract from "../artifacts/contracts/docks/base/BaseMessageDock.sol/BaseMessageDock.json";
import { IMessageDock } from "./interfaces/IMessageDock";

enum MessagingProviders {
  Axelar = "Axelar",
  AxelarTestnet = "AxelarTestnet",
  Celer = "Celer",
  DarwiniaLCMP = "DarwiniaLCMP",
  DarwiniaS2S = "DarwiniaS2S",
  LayerZero = "LayerZero",
}

async function getMessageDock(
  provider: ethers.providers.Provider,
  dockAddress: string
) {
  const dockContract = new ethers.Contract(
    dockAddress,
    BaseMessageDockContract.abi,
    provider
  );

  let estimateFee: IEstimateFee = await buildEstimateFunction(
    provider,
    dockContract
  );

  const result: IMessageDock = {
    address: dockAddress,

    getLocalChainId: async () => {
      return await dockContract.getLocalChainId();
    },

    getOutboundLane: async (remoteChainId: number) => {
      const outboundLane = await dockContract.outboundLanes(remoteChainId);
      return {
        fromChainId: await result.getLocalChainId(),
        fromDockAddress: dockAddress,
        toChainId: outboundLane["toChainId"],
        toDockAddress: outboundLane["toDockAddress"],
      };
    },

    getRemoteDockAddress: async (remoteChainId: number) => {
      const lane = await dockContract.outboundLanes(remoteChainId);
      return lane["toDockAddress"];
    },

    estimateFee: async (
      remoteChainId: number,
      messagePayload: string,
      feeMultiplier: number,
      params
    ) => {
      const remoteDockAddress = await result.getRemoteDockAddress(
        remoteChainId
      );

      return await estimateFee(
        await dockContract.getLocalChainId(),
        dockAddress,
        remoteChainId,
        remoteDockAddress,
        messagePayload,
        feeMultiplier,
        params
      );
    },

    getProviderName: async () => {
      return await dockContract.getProviderName();
    },
  };

  return result;
}

async function buildEstimateFunction(
  provider: ethers.providers.Provider,
  dockContract: ethers.Contract
) {
  const providerName = await dockContract.getProviderName();
  const dockAddress = dockContract.address;
  let estimateFee: IEstimateFee;
  if (providerName == MessagingProviders.LayerZero) {
    estimateFee = await layerzero.buildEstimateFeeFunction(
      provider,
      dockAddress
    );
  } else if (providerName == MessagingProviders.Axelar) {
    estimateFee = await axelar.buildEstimateFeeFunction(
      provider,
      dockAddress,
      axelar.Environment.MAINNET
    );
  } else if (providerName == MessagingProviders.AxelarTestnet) {
    estimateFee = await axelar.buildEstimateFeeFunction(
      provider,
      dockAddress,
      axelar.Environment.TESTNET
    );
  } else {
    throw new Error("Unsupported Messaging Provider");
  }
  return estimateFee;
}

export { getMessageDock, MessagingProviders };
