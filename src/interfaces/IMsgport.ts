import { IDock } from "./IDock";
import { ethers } from "ethers";
import { IDockSelectionStrategy } from "./IDockSelectionStrategy";
import { DockType } from "../dock";

export type IMsgport = {
  getLocalChainId: () => Promise<number>;

  getLocalDockAddress: (
    toChainId: number,
    selectDock: IDockSelectionStrategy
  ) => Promise<string>;

  getDock: (
    toChainId: number,
    selectDock: IDockSelectionStrategy
  ) => Promise<IDock>;

  getLocalDockAddressesByToChainId: (toChainId: number) => Promise<string[]>;

  send: (
    toChainId: number,
    toDappAddress: string,
    messagePayload: string,
    dockType: DockType,
    params: string
  ) => Promise<ethers.providers.TransactionResponse>;
};
