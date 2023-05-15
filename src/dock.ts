import { ethers } from "ethers";
import { IEstimateFee } from "./interfaces/IEstimateFee";
import { layerzero } from "./layerzero/index";
import { axelar } from "./axelar/index";

enum DockType {
  Axelar = 0,
  AxelarTestnet = 1,
  Celer = 2,
  Darwinia = 3,
  DarwiniaS2S = 4,
  DarwiniaXcmp = 5,
  LayerZero = 6,
}

async function getDock(
  provider: ethers.providers.Provider,
  dockAddress: string,
  dockType: DockType
) {
  const dock = new ethers.Contract(
    dockAddress,
    [
      "function getRemoteDockAddress() public view returns (address)",
      "function remoteChainId() public view returns (uint256)",
    ],
    provider
  );

  const remoteChainId = await dock.remoteChainId();

  let estimateFee: IEstimateFee;
  if (dockType == DockType.LayerZero) {
    estimateFee = await layerzero.buildEstimateFeeFunction(
      provider,
      dockAddress
    );
  } else if (dockType == DockType.Axelar) {
    estimateFee = await axelar.buildEstimateFeeFunction(
      provider,
      dockAddress,
      axelar.Environment.MAINNET
    );
  } else if (dockType == DockType.AxelarTestnet) {
    estimateFee = await axelar.buildEstimateFeeFunction(
      provider,
      dockAddress,
      axelar.Environment.TESTNET
    );
  } else {
    throw new Error("Unsupported dock type");
  }

  return {
    remoteChainId: remoteChainId,

    address: dockAddress,

    getRemoteDockAddress: async () => {
      return await dock.getRemoteDockAddress();
    },

    estimateFee: async (messagePayload: string) => {
      const remoteDockAddress = await dock.getRemoteDockAddress();

      return await estimateFee(dockAddress, remoteDockAddress, messagePayload);
    },
  };
}

export { getDock, DockType };
