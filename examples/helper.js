const hre = require("hardhat");

async function deployMsgport(network, localChainId) {
  hre.changeNetwork(network);
  const DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.deploy(localChainId, {
    gasLimit: 1000000,
  });
  await msgport.deployed();
  console.log(`${network} msgport: ${msgport.address}`);
}

async function deployDock(
  localNetwork,
  localMsgportAddress,
  remoteChainId,
  dockName,
  dockArgs
) {
  // Deploy dock
  hre.changeNetwork(localNetwork);
  let Dock = await hre.ethers.getContractFactory(dockName);
  let dock = await Dock.deploy(
    localMsgportAddress,
    remoteChainId,
    ...dockArgs,
    {
      gasLimit: 2000000,
    }
  );
  await dock.deployed();
  console.log(`${localNetwork} ${dockName}: ${dock.address}`);

  // Add it to the msgport
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.attach(localMsgportAddress);
  await (
    await msgport.setDock(remoteChainId, dock.address, { gasLimit: 50000 })
  ).wait();
  console.log(
    `··${localNetwork} ${dockName} ${dock.address} set on msgport ${localMsgportAddress}`
  );

  return dock.address;
}

async function setRemoteDock(
  network,
  dockName,
  dockAddress,
  remoteDockAddress
) {
  hre.changeNetwork(network);
  let Dock = await hre.ethers.getContractFactory(dockName);
  let dock = await Dock.attach(dockAddress);
  await (
    await dock.setRemoteDockAddress(remoteDockAddress, { gasLimit: 50000 })
  ).wait();
  console.log(
    `${network} ${dockName} ${dockAddress} set remote dock ${remoteDockAddress}`
  );
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

      console.log(
        network,
        msgportAddress,
        toChainId,
        toDappAddress,
        messagePayload,
        fee,
        params
      );
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
  console.log(`${network} receiver: ${receiver.address}`);
  return receiver.address;
}

async function setupDocks(
  senderChain,
  senderMsgportAddress,
  senderDockName,
  senderDockParams,
  receiverChain,
  receiverMsgportAddress,
  receiverDockName,
  receiverDockParams
) {
  // Prepare sender and receiver info
  const senderChainId = await getChainId(senderChain);
  const receiverChainId = await getChainId(receiverChain);

  // Deploy sender Dock
  const senderDockAddress = await deployDock(
    senderChain,
    senderMsgportAddress,
    receiverChainId,
    senderDockName,
    senderDockParams
  );

  // Deploy receiver Dock
  const receiverDockAddress = await deployDock(
    receiverChain,
    receiverMsgportAddress,
    senderChainId,
    receiverDockName,
    receiverDockParams
  );

  // Configure remote Dock
  await setRemoteDock(
    senderChain,
    senderDockName,
    senderDockAddress,
    receiverDockAddress
  );
  await setRemoteDock(
    receiverChain,
    receiverDockName,
    receiverDockAddress,
    senderDockAddress
  );
}

async function sendMessage(
  senderChain,
  senderMsgportAddress,
  receiverChain,
  message,
  estimateFee,
  params = "0x"
) {
  // Deploy receiver
  const receiverAddress = await deployReceiver(receiverChain);

  // Send message to receiver
  const receiverChainId = await getChainId(receiverChain);
  const msgport = await getMsgport(senderChain, senderMsgportAddress);
  msgport.send(receiverChainId, receiverAddress, message, estimateFee, params);
}

exports.deployMsgport = deployMsgport;
exports.deployDock = deployDock;
exports.setRemoteDock = setRemoteDock;
exports.getMsgport = getMsgport;
exports.deployReceiver = deployReceiver;
exports.getChainId = getChainId;
exports.setupDocks = setupDocks;
exports.sendMessage = sendMessage;
