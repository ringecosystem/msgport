const { deployMsgport } = require("../helper");

async function main() {
  await deployMsgport("goerli");
  await deployMsgport("pangolin");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
