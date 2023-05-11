const {
  AxelarGMPRecoveryAPI,
  Environment,
} = require("@axelar-network/axelarjs-sdk");

async function main() {
  const sdk = new AxelarGMPRecoveryAPI({
    environment: Environment.TESTNET,
  });
  const txHash =
    "0x9a7cbba4fa3b9045b92e84bc20bb1084dbdc468f15e906549726b934e31e367b";
  const txStatus = await sdk.queryTransactionStatus(txHash);
  console.log(txStatus["status"]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
