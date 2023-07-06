export type ILineSelectionStrategy = (
  lineAddresses: string[]
) => Promise<string>;
