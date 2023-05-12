const hre = require("hardhat");
const { getMsgport, deployReceiver } = require("../helper");

function buildEstimateFeeFunction(network, endpointAddress) {
  hre.changeNetwork(network);
  const abi = ["function fee() public view returns (uint128)"];
  const messageEndpoint = new hre.ethers.Contract(
    endpointAddress,
    abi,
    hre.ethers.provider
  );
  return async (_fromDappAddress, _toDappAddress, _messagePayload) => {
    return await messageEndpoint.fee();
  };
}

async function main() {
  const senderChain = "pangolin";
  const receiverChain = "pangoro";

  // Deploy receiver
  await deployReceiver(receiverChain);

  // Send message to receiver
  const estimateFee = buildEstimateFeeFunction(
    senderChain,
    "0xE8C0d3dF83a07892F912a71927F4740B8e0e04ab" // pangolin endpoint address
  );
  const pangolinMsgportAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F";
  const msgport = await getMsgport(senderChain, pangolinMsgportAddress);
  // params:
  //  - specVersion: uint32
  //  - gasLimit: uint256
  const params = hre.ethers.utils.defaultAbiCoder.encode(
    ["uint32", "uint256"],
    ["6021", "3000000"]
  );
  msgport.send(receiver.address, "0x12345678", estimateFee, params);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
