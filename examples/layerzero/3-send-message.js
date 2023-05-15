const { getMsgport, getChainId, deployReceiver } = require("../helper");
const hre = require("hardhat");

async function main() {
  const senderChain = "fantomTestnet";
  const receiverChain = "baseGoerliTestnet";
  const senderMsgportAddress = "0x9434A7c2a656CD1B9d78c90369ADC0c2C54F5599"; // <------- change this
  const estimateFee = buildEstimateFeeFunction(
    senderChain,
    "0x7dcAD72640F835B0FA36EFD3D6d3ec902C7E5acf", // sender endpoint address
    10160, // dstChainId
    "0x26a4fAE216359De954a927dEbaB339C09Dbf7e8e" // userApplication, fantomTestnet LayerZeroDock
  );

  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  // Send message to receiver
  const receiverChainId = await getChainId(receiverChain);
  const msgport = await getMsgport(senderChain, senderMsgportAddress);
  msgport.send(
    receiverChainId,
    receiverAddress,
    "0x12345678",
    estimateFee,
    "0x"
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
