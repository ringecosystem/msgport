const { deployReceiver } = require("../helper");
const hre = require("hardhat");
const {
  getMsgport,
  createDefaultDockSelectionStrategy,
} = require("../../dist/src/index");

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "moonbaseAlpha";

  ///////////////////////////////////////
  // deploy receiver
  ///////////////////////////////////////
  hre.changeNetwork(receiverChain);
  const receiverAddress = await deployReceiver(receiverChain);
  const receiverChainId = (await hre.ethers.provider.getNetwork())["chainId"];
  console.log(
    `On ${receiverChain}, chain id: ${receiverChainId}, receiver address: ${receiverAddress}`
  );

  ///////////////////////////////////////
  // send message to receiver
  ///////////////////////////////////////
  hre.changeNetwork(senderChain);
  //  1. get msgport
  const msgport = await getMsgport(
    await hre.ethers.getSigner(),
    "0x05f8D1E45A04f5D7336c5BcabfCAc54Bd59c97f4" // <------- change this, see 0-setup-msgports.js
  );

  //  2. get the dock selection strategy
  const selectLastDock = async (_) =>
    "0x6c1D7335a362138e5E5c8831C838a46d88316f5C"; // <------- change this to the sender dock address, see 1-deploy-dock.js

  //  3. send message
  // https://layerzero.gitbook.io/docs/evm-guides/advanced/relayer-adapter-parameters
  let params = hre.ethers.utils.solidityPack(
    ["uint16", "uint256"],
    [1, 1000000]
  );
  const tx = await msgport.send(
    receiverChainId,
    selectLastDock,
    receiverAddress,
    "0x12345678",
    1.1,
    params
  );

  console.log(
    `Message sent: https://testnet.layerzeroscan.com/tx/${
      (await tx.wait()).transactionHash
    }`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
