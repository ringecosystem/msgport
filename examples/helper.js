const hre = require("hardhat");

async function deployLineRegistry(chainId, args = {}) {
  const LineRegistry = await hre.ethers.getContractFactory("LineRegistry");
  const lineRegistry = await LineRegistry.deploy(chainId, args);
  await lineRegistry.deployed();
  return lineRegistry.address;
}

async function deployLine(
  // for deploy the line
  lineName,
  localLineRegistryAddress,
  chainIdMappingAddress,
  lineArgs,
  // for adding the remote line to the lineRegistry
  remoteChainId,
  // deploy tx args
  deployGasLimit = 4000000,
  deployGasPrice = hre.ethers.utils.parseUnits("10", "gwei"),
  // newOutboundLane tx args
  addRemoteLineGasLimit = 100000
) {
  let Line = await hre.ethers.getContractFactory(lineName);
  let line = await Line.deploy(
    localLineRegistryAddress,
    chainIdMappingAddress,
    ...lineArgs,
    {
      gasLimit: deployGasLimit,
      gasPrice: deployGasPrice,
    }
  );
  await line.deployed();

  // Add it to the lineRegistry
  let LineRegistry = await hre.ethers.getContractFactory("LineRegistry");
  const lineRegistry = await LineRegistry.attach(localLineRegistryAddress);
  await (
    await lineRegistry.addLocalLine(remoteChainId, line.address, {
      gasLimit: addRemoteLineGasLimit,
    })
  ).wait();

  return line;
}

async function getLineRegistry(network, lineRegistryAddress) {
  return {
    send: async (
      toChainId,
      toDappAddress,
      messagePayload,
      estimateFee,
      params = "0x"
    ) => {
      hre.changeNetwork(network);
      const LineRegistry = await hre.ethers.getContractFactory(
        "LineRegistry"
      );
      const lineRegistry = await LineRegistry.attach(lineRegistryAddress);

      // Estimate fee
      const fromDappAddress = (await hre.ethers.getSigner()).address;
      const fee = await estimateFee(
        fromDappAddress,
        toDappAddress,
        messagePayload
      );
      console.log(`cross-chain fee: ${fee} wei.`);

      // Send message
      const tx = await lineRegistry.send(
        toChainId,
        toDappAddress,
        messagePayload,
        fee,
        params,
        {
          value: hre.ethers.BigNumber.from(fee),
        }
      );
      console.log(
        `message ${messagePayload} sent to ${toDappAddress} through ${network} lineRegistry ${lineRegistryAddress}`
      );
      console.log(`tx hash: ${(await tx.wait()).transactionHash}`);
    },
  };
}

async function getChainId(network) {
  hre.changeNetwork(network);
  return (await hre.ethers.provider.getNetwork())["chainId"];
}

async function deployReceiver(network) {
  hre.changeNetwork(network);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  return receiver.address;
}

async function sendMessage(
  senderChain,
  senderLineRegistryAddress,
  receiverChain,
  receiverAddress,
  message,
  estimateFee,
  params = "0x"
) {
  // Send message to receiver
  const receiverChainId = await getChainId(receiverChain);
  const lineRegistry = await getLineRegistry(senderChain, senderLineRegistryAddress);
  lineRegistry.send(receiverChainId, receiverAddress, message, estimateFee, params);
}

exports.puts = (obj) => {
  for (const [key, value] of Object.entries(obj)) {
    console.log(`  ${key}: ${value}`);
  }
};

exports.deployLineRegistry = deployLineRegistry;
exports.deployLine = deployLine;
exports.getLineRegistry = getLineRegistry;
exports.deployReceiver = deployReceiver;
exports.getChainId = getChainId;
exports.sendMessage = sendMessage;
