const hre = require("hardhat");

async function getMsgport(network, msgportAddress) {
  return {
    send: async (toDappAddress, msg, executionGas = 0, gasPrice = 0) => {
      hre.changeNetwork(network);
      const DefaultMsgport = await hre.ethers.getContractFactory(
        "DefaultMsgport"
      );
      const msgport = await DefaultMsgport.attach(msgportAddress);

      const fromDappAddress = (await hre.ethers.getSigner()).address;
      const fee = await msgport.estimateFee(
        fromDappAddress,
        toDappAddress,
        msg,
        executionGas,
        gasPrice
      );
      console.log(`cross-chain fee: ${fee} wei.`);

      const tx = await msgport.send(
        toDappAddress,
        msg,
        executionGas,
        gasPrice,
        {
          value: fee,
        }
      );
      console.log(
        `message ${msg} sent to ${toDappAddress} through ${network} msgport ${msgportAddress}`
      );
      console.log(
        `https://pangoro.subscan.io/extrinsic/${
          (await tx.wait()).transactionHash
        }`
      );
    },
  };
}

async function main() {
  // Deploy receiver
  hre.changeNetwork("pangoro");
  const ExampleReceiverDapp = await hre.ethers.getContractFactory(
    "ExampleReceiverDapp"
  );
  const receiver = await ExampleReceiverDapp.deploy();
  await receiver.deployed();
  console.log(`receiver: ${receiver.address}`);

  // Send message to receiver
  const pangolinMsgportAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F";
  const msgport = await getMsgport("pangolin", pangolinMsgportAddress);
  msgport.send(receiver.address, "0x12345678");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
