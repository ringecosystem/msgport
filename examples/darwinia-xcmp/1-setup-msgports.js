const { deployMsgport } = require("../helper");

async function main() {
  await deployMsgport("pangolin");
  await deployMsgport("rocstar");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
