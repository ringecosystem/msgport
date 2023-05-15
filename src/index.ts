import { ethers } from "ethers";
import { getMsgport, DockType } from "./msgport";

async function main(): Promise<void> {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://rpc.testnet.fantom.network"
  );

  const msgport = await getMsgport(
    provider,
    "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"
  );

  const dock = await msgport.getDock(
    84531, // Base testnet chain ID
    DockType.LayerZero
  );

  const fee = await dock.estimateFee("0x12345678");
  console.log(`cross-chain fee: ${fee} wei.`);
}

main();