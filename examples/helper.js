const hre = require("hardhat");

async function deployMsgport(chainId, args = {}) {
  const DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.deploy(chainId, args);
  await msgport.deployed();
  return msgport.address;
}

async function deployDock(
  // for deploy the dock
  dockName,
  localMsgportAddress,
  chainIdMappingAddress,
  dockArgs,
  // for adding the remote dock to the msgport
  remoteChainId,
  // deploy tx args
  deployGasLimit = 4000000,
  deployGasPrice = hre.ethers.utils.parseUnits("2", "gwei"),
  // addRemoteDock tx args
  addRemoteDockGasLimit = 100000
) {
  let Dock = await hre.ethers.getContractFactory(dockName);
  let dock = await Dock.deploy(
    localMsgportAddress,
    chainIdMappingAddress,
    ...dockArgs,
    {
      gasLimit: deployGasLimit,
      gasPrice: deployGasPrice,
    }
  );
  await dock.deployed();

  // Add it to the msgport
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.attach(localMsgportAddress);
  await (
    await msgport.addLocalDock(remoteChainId, dock.address, {
      gasLimit: addRemoteDockGasLimit,
    })
  ).wait();

  return dock;
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
      const DefaultMsgport = await hre.ethers.getContractFactory(
        "DefaultMsgport"
      );
      const msgport = await DefaultMsgport.attach(msgportAddress);

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

exports.deployMsgport = deployMsgport;
exports.deployDock = deployDock;
exports.getMsgport = getMsgport;
exports.deployReceiver = deployReceiver;
exports.getChainId = getChainId;
exports.sendMessage = sendMessage;
