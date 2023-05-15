export type IEstimateFee = (
  fromDappAddress: string,
  toDappAddress: string,
  messagePayload: string
) => Promise<number>;
