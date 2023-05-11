const { deployMsgport } = require("../helper");

// fantomTestnet msgport: 0x0B4972B183C19B615658a928e6cB606D76B18dEd
// moonbaseAlpha msgport: 0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94
async function main() {
  await deployMsgport("fantomTestnet");
  await deployMsgport("moonbaseAlpha");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
