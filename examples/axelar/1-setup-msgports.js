const { deployMsgport } = require("../helper");

// fantomTestnet msgport: 0x0B4972B183C19B615658a928e6cB606D76B18dEd
// polygonTestnet msgport: 0x0E23B6e7009Ef520298ccFD8FC3F67E43223B77c
async function main() {
  await deployMsgport("fantomTestnet");
  await deployMsgport("polygonTestnet");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
