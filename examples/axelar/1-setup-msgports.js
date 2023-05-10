const { deployMsgport } = require("../helper");

async function main() {
  await deployMsgport("fantomTestnet");
  await deployMsgport("polygonTestnet");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
