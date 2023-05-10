const { deployMsgport } = require("../helper");

// fantom msgport: 0x7bB47867d8BA255c79e6f5BaCAC6e3194D05C273
// bnbChain msgport: 0x770497281303Cdb2e0252B82AdEEA1d61896dD43
async function main() {
  await deployMsgport("fantom");
  await deployMsgport("bnbChain");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
