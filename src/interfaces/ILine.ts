export type ILine = {
  address: string;

  getLocalChainId: () => Promise<number>;

  getOutboundLane: (remoteChainId: number) => Promise<any>;

  getRemoteLineAddress: (remoteChainId: number) => Promise<string>;

  estimateFee: (
    remoteChainId: number,
    messagePayload: string,
    feeMultiplier: number,
    params: string
  ) => Promise<number>;
};
