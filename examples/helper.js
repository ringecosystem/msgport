const hre = require("hardhat");

async function deployMsgport(chainId, args = {}) {
  const MessagePort = await hre.ethers.getContractFactory("MessagePort");
  const msgport = await MessagePort.deploy(chainId, args);
  await msgport.deployed();
  return msgport.address;
}

async function deployLine(
  // for deploy the line
  lineName,
  localMsgportAddress,
  chainIdMappingAddress,
  lineArgs,
  // for adding the remote line to the msgport
  remoteChainId,
  // deploy tx args
  deployGasLimit = 4000000,
  deployGasPrice = hre.ethers.utils.parseUnits("10", "gwei"),
  // newOutboundLane tx args
  addRemoteLineGasLimit = 100000
) {
  let Line = await hre.ethers.getContractFactory(lineName);
  let line = await Line.deploy(
    localMsgportAddress,
    chainIdMappingAddress,
    ...lineArgs,
    {
      gasLimit: deployGasLimit,
      gasPrice: deployGasPrice,
    }
  );
  await line.deployed();

  // Add it to the msgport
  let MessagePort = await hre.ethers.getContractFactory("MessagePort");
  const msgport = await MessagePort.attach(localMsgportAddress);
  await (
    await msgport.addLocalLine(remoteChainId, line.address, {
      gasLimit: addRemoteLineGasLimit,
    })
  ).wait();

  return line;
}

async function getMsgport(network, msgportAddress) {
  return {
    send: async (
      toChainId,
      toDappAddress,
      messagePayload,
      estimateFee,
      params = "0x"
    ) => {
      hre.changeNetwork(network);
      const MessagePort = await hre.ethers.getContractFactory(
        "MessagePort"
      );
      const msgport = await MessagePort.attach(msgportAddress);

      // Estimate fee
      const fromDappAddress = (await hre.ethers.getSigner()).address;
      const fee = await estimateFee(
        fromDappAddress,
        toDappAddress,
        messagePayload
      );
      console.log(`cross-chain fee: ${fee} wei.`);

      // Send message
      const tx = await msgport.send(
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
        `message ${messagePayload} sent to ${toDappAddress} through ${network} msgport ${msgportAddress}`
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
  senderMsgportAddress,
  receiverChain,
  receiverAddress,
  message,
  estimateFee,
  params = "0x"
) {
  // Send message to receiver
  const receiverChainId = await getChainId(receiverChain);
  const msgport = await getMsgport(senderChain, senderMsgportAddress);
  msgport.send(receiverChainId, receiverAddress, message, estimateFee, params);
}

exports.puts = (obj) => {
  for (const [key, value] of Object.entries(obj)) {
    console.log(`  ${key}: ${value}`);
  }
};

exports.deployMsgport = deployMsgport;
exports.deployLine = deployLine;
exports.getMsgport = getMsgport;
exports.deployReceiver = deployReceiver;
exports.getChainId = getChainId;
exports.sendMessage = sendMessage;
