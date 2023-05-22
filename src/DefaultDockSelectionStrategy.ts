import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";
import { ethers } from "ethers";

export const createDefaultDockSelectionStrategy = (
  provider: ethers.providers.Provider
): IDockSelectionStrategy => {
  const selectDock: IDockSelectionStrategy = async (
    dockAddresses: string[]
  ) => {
    return dockAddresses[0];
  };

  return selectDock;
};
