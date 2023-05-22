export type IDock = {
  remoteChainId: number;

  address: string;

  estimateFee: (messagePayload: string) => Promise<number>;
};
