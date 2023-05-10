const { deployMsgport } = require("../helper");

// bscTestnet msgport: 0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573
// fantomTestnet msgport: 0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573
async function main() {
  await deployMsgport("bscTestnet");
  await deployMsgport("fantomTestnet");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
