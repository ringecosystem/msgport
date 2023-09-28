import { ILine } from "./ILine";
import { ethers } from "ethers";
import { ILineSelectionStrategy } from "./ILineSelectionStrategy";
import { ChainId } from "../chain-ids";

export type ILineRegistry = {
  getLocalChainId: () => Promise<number>;

  getLocalLineAddress: (
    toChainId: ChainId,
    selectLine: ILineSelectionStrategy
  ) => Promise<string>;

  getLine: (
    toChainId: ChainId,
    selectLine: ILineSelectionStrategy
  ) => Promise<ILine>;

  getLocalLineAddressesByToChainId: (toChainId: ChainId) => Promise<string[]>;

  estimateFee: (
    toChainId: ChainId,
    selectLine: ILineSelectionStrategy,
    messagePayload: string,
    feeMultiplier: number,
    params: string
  ) => Promise<number>;

  send: (
    toChainId: ChainId,
    selectLine: ILineSelectionStrategy,
    toDappAddress: string,
    messagePayload: string,
    feeMultiplier: number,
    params: string
  ) => Promise<ethers.providers.TransactionResponse | null>;
};
