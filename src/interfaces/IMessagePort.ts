import { IMessageDock } from "./IMessageDock";
import { ethers } from "ethers";
import { IDockSelectionStrategy } from "./IDockSelectionStrategy";
import { ChainId } from "../chain-ids";

export type IMessagePort = {
  getLocalChainId: () => Promise<number>;

  getLocalDockAddress: (
    toChainId: ChainId,
    selectDock: IDockSelectionStrategy
  ) => Promise<string>;

  getDock: (
    toChainId: ChainId,
    selectDock: IDockSelectionStrategy
  ) => Promise<IMessageDock>;

  getLocalDockAddressesByToChainId: (toChainId: ChainId) => Promise<string[]>;

  estimateFee: (
    toChainId: ChainId,
    selectDock: IDockSelectionStrategy,
    messagePayload: string,
    feeMultiplier: number,
    params: string
  ) => Promise<number>;

  send: (
    toChainId: ChainId,
    selectDock: IDockSelectionStrategy,
    toDappAddress: string,
    messagePayload: string,
    feeMultiplier: number,
    params: string
  ) => Promise<ethers.providers.TransactionResponse | null>;
};
