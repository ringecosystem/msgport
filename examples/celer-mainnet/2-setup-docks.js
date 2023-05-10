const { deployDock, setRemoteDock } = require("../helper");

// fantom CelerDock dock: 0x64944F4A62a28ccD2D6fdc47Ba9511FfDB802E2C
// bnbChain CelerDock dock: 0x08f17e8c83DdC3F05543b7F0b61977F6648521a7
async function main() {
  const fantomMsgportAddress = "0x7bB47867d8BA255c79e6f5BaCAC6e3194D05C273";
  const bnbChainMsgportAddress = "0x770497281303Cdb2e0252B82AdEEA1d61896dD43";

  const fantomMessageBus = "0xFF4E183a0Ceb4Fa98E63BbF8077B929c8E5A2bA4";
  const bnbChainMessageBus = "0x95714818fdd7a5454f73da9c777b3ee6ebaeea6b";

  const fantomChainId = 250;
  const bnbChainChainId = 56;

  // fantom dock
  const fantomDockAddress = await deployDock(
    "fantom",
    fantomMsgportAddress,
    "CelerDock",
    [fantomMsgportAddress, fantomMessageBus, fantomChainId, bnbChainChainId]
  );

  // bnbChain dock
  const bnbChainDockAddress = await deployDock(
    "bnbChain",
    bnbChainMsgportAddress,
    "CelerDock",
    [bnbChainMsgportAddress, bnbChainMessageBus, bnbChainChainId, fantomChainId]
  );

  // CONNECT TO EACH OTHER
  await setRemoteDock(
    "fantom",
    "CelerDock",
    fantomDockAddress,
    bnbChainDockAddress
  );
  await setRemoteDock(
    "bnbChain",
    "CelerDock",
    bnbChainDockAddress,
    fantomDockAddress
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
