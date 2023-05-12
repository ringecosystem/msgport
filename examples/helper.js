const hre = require("hardhat");

async function deployMsgport(network) {
  hre.changeNetwork(network);
  const DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.deploy({ gasLimit: 800000 });
  await msgport.deployed();
  console.log(`${network} msgport: ${msgport.address}`);
}

async function deployDock(network, msgportAddress, dockName, dockArgs) {
  hre.changeNetwork(network);
  let Dock = await hre.ethers.getContractFactory(dockName);
  let dock = await Dock.deploy(...dockArgs, { gasLimit: 2000000 });
  await dock.deployed();
  console.log(`${network} ${dockName}: ${dock.address}`);

  // Add it to the msgport
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = await DefaultMsgport.attach(msgportAddress);
  await (await msgport.setDock(dock.address, { gasLimit: 50000 })).wait();
  console.log(
    `┗${network} ${dockName} ${dock.address} set on msgport ${msgportAddress}`
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
    send: async (toDappAddress, messagePayload, estimateFee, params) => {
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

async function deployReceiver(network) {
  hre.changeNetwork(network);
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`${network} receiver: ${receiver.address}`);
}

exports.deployMsgport = deployMsgport;
exports.deployDock = deployDock;
exports.setRemoteDock = setRemoteDock;
exports.getMsgport = getMsgport;
exports.deployReceiver = deployReceiver;
