import { getMessageDock } from "../dock";
import { ethers } from "ethers";

async function main(): Promise<void> {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://endpoints.omniatech.io/v1/bsc/testnet/public"
  );

  const dock = await getMessageDock(
    provider,
    "0x3d5F09572DdD5f52A70c32d0EC6F67b4d18e62bB"
  );

  const dockAddress = dock.address;
  console.log(`dockAddress: ${dockAddress}`);

  const localChainId = await dock.getLocalChainId();
  console.log(`localChainId: ${localChainId}`);

  const outboundLane = await dock.getOutboundLane(80001);
  console.log(`outboundLane: `);
  console.log(` fromChainId: ${outboundLane.fromChainId}`);
  console.log(` fromDockAddress: ${outboundLane.fromDockAddress}`);
  console.log(` toChainId: ${outboundLane.toChainId}`);
  console.log(` toDockAddress: ${outboundLane.toDockAddress}`);

  const remoteDockAddress = await dock.getRemoteDockAddress(80001);
  console.log(`remoteDockAddress: ${remoteDockAddress}`);

  const estimateFee = await dock.estimateFee(80001, "0x12345678", 1.1, "0x");
  console.log(`estimateFee: ${estimateFee}`);
}
main();
