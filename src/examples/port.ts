import { getMessagePort } from "../port";
import { BytesLike, ethers } from "ethers";

import "dotenv/config";

async function main(): Promise<void> {
  const provider = new ethers.providers.JsonRpcProvider(
    "https://endpoints.omniatech.io/v1/bsc/testnet/public"
  );

  const signer: ethers.Signer = new ethers.Wallet(
    process.env.PRIVATE_KEY as BytesLike,
    provider
  );

  const port = await getMessagePort(
    signer,
    "0x9e974C1a82CF5893f9409a323Fe391263fcB3c4d"
  );

  const tx = await port.send(
    80001,
    async (_) => "0x3d5F09572DdD5f52A70c32d0EC6F67b4d18e62bB",
    "0xe13084f8fF65B755E37d95F49edbD49ca26feE13",
    "0x12345678",
    1.1,
    ethers.utils.solidityPack(["uint16", "uint256"], [1, 300000])
  );
  console.log(tx);
}

main();
