import { IDockSelectionStrategy } from "./interfaces/IDockSelectionStrategy";
import { ethers } from "ethers";

// Default dock selection strategy is to select the last dock in the list
export const createDefaultDockSelectionStrategy = (
  provider: ethers.providers.Provider
): IDockSelectionStrategy => {
  const selectDock: IDockSelectionStrategy = async (
    dockAddresses: string[]
  ) => {
    return dockAddresses[dockAddresses.length - 1];
  };

  return selectDock;
};
