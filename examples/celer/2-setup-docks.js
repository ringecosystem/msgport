const { deployDock, setRemoteDock } = require("../helper");

async function main() {
  const bscMsgportAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573";
  const fantomMsgportAddress = "0x07414d2B62A4Dd7fd1750C6DfBd9D38c250Cc573";

  const bscMessageBus = "0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA";
  const fantomMessageBus = "0xb92d6933A024bcca9A21669a480C236Cbc973110";
  const bscChainId = 97;
  const fantomChainId = 4002;

  // bsc dock
  const bscDockAddress = await deployDock(
    "bscTestnet",
    bscMsgportAddress,
    "CelerDock",
    [bscMsgportAddress, bscMessageBus, bscChainId, fantomChainId]
  );

  // fantom dock
  const fantomDockAddress = await deployDock(
    "fantomTestnet",
    fantomMsgportAddress,
    "CelerDock",
    [fantomMsgportAddress, fantomMessageBus, fantomChainId, bscChainId]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock("bscTestnet", bscDockAddress, fantomDockAddress);
  await setRemoteDock("fantomTestnet", fantomDockAddress, bscDockAddress);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
