export type ILine = {
  address: string;

  getLocalChainId: () => Promise<number>;

  getRemoteLineAddress: (remoteChainId: number) => Promise<string>;

  estimateFee: (
    remoteChainId: number,
    messagePayload: string,
    feeMultiplier: number,
    params: string
  ) => Promise<number>;
};
