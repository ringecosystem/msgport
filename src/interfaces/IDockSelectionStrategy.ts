export type IDockSelectionStrategy = (
  dockAddresses: string[]
) => Promise<string>;
