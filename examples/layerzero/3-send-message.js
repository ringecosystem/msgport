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
  const receiverAddress = "0x8205b173786DC663d328D1CD9AdBCCb3877aBC6E"; // await deployReceiver(receiverChain);
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
    "0x308f61D8a88f010146C4Ec15897ABc1EFc57c80a" // <------- change this, see examples/axelar/1-setup-msgports.js
  );

  //  2. get the default dock selection strategy
  const selectLastDock = createDefaultDockSelectionStrategy(
    hre.ethers.provider
  );

  //  3. send message
  const tx = await msgport.send(
    receiverChainId,
    selectLastDock,
    receiverAddress,
    "0x12345678",
    1.1
  );

  console.log(
    `Message sent: https://testnet.layerzeroscan.com/tx/${
      (await tx.wait()).transactionHash
    }`
  );
}

function buildEstimateFeeFunction(
  network,
  endpointAddress,
  dstChainId,
  senderDockAddress
) {
  hre.changeNetwork(network);
  const abi = [
    "function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee)",
  ];
  const endpoint = new hre.ethers.Contract(
    endpointAddress,
    abi,
    hre.ethers.provider
  );
  return async (fromDappAddress, toDappAddress, messagePayload) => {
    const payload = hre.ethers.utils.defaultAbiCoder.encode(
      ["address", "address", "address", "bytes"],
      [senderDockAddress, fromDappAddress, toDappAddress, messagePayload]
    );
    const result = await endpoint.estimateFees(
      dstChainId,
      senderDockAddress,
      payload,
      false,
      "0x"
    );
    return result.nativeFee;
  };
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
