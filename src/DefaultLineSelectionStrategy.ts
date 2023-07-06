import { ILineSelectionStrategy } from "./interfaces/ILineSelectionStrategy";
import { ethers } from "ethers";

// Default line selection strategy is to select the last line in the list
export const createDefaultLineSelectionStrategy = (
  provider: ethers.providers.Provider
): ILineSelectionStrategy => {
  const selectLine: ILineSelectionStrategy = async (
    lineAddresses: string[]
  ) => {
    return lineAddresses[lineAddresses.length - 1];
  };

  return selectLine;
};
