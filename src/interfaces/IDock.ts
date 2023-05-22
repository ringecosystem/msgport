export type IDock = {
  address: string;

  getLocalChainId: () => Promise<number>;

  getRemoteDockAddress: (remoteChainId: number) => Promise<string>;

  estimateFee: (
    remoteChainId: number,
    messagePayload: string
  ) => Promise<number>;
};
