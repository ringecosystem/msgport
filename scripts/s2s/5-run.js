const hre = require("hardhat");

async function main() {
  hre.changeNetwork("pangolin");

  const pangolinDappAddress = process.argv[2];
  const pangoroDappAddress = process.argv[3];

  const S2sPangolinDapp = await hre.ethers.getContractFactory(
    "S2sPangolinDapp"
  );
  const s2sPangolinDapp = S2sPangolinDapp.attach(pangolinDappAddress);

  const adapterId = 3;
  const fee = await estimateFee(s2sPangolinDapp, adapterId);
  console.log(`Market fee: ${fee} wei`);

  // Run
  const tx = await s2sPangolinDapp.remoteAdd(adapterId, pangoroDappAddress, {
    value: fee,
  });
  console.log(`tx: ${(await tx.wait()).transactionHash}`);

  // check result
  while (true) {
    printResult(pangoroDappAddress);
    await sleep(1000 * 60 * 5);
  }
}

async function printResult(pangoroDappAddress) {
  hre.changeNetwork("pangoro");
  const S2sPangoroDapp = await hre.ethers.getContractFactory("S2sPangoroDapp");
  const s2sPangoroDapp = S2sPangoroDapp.attach(pangoroDappAddress);
  console.log(
    `s2sPangoroDapp ${pangoroDappAddress} sum is ${await s2sPangoroDapp.sum()}`
  );
}

async function estimateFee(pangolinDapp, adapterId) {
  const msgportAddress = await pangolinDapp.msgportAddress();
  console.log(`msgportAddress: ${msgportAddress}`);
  const DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const msgport = DefaultMsgport.attach(msgportAddress);

  const msgportAddress = await msgport.msgportAddresses(adapterId);
  const DarwiniaS2sAdapter = await hre.ethers.getContractFactory(
    "DarwiniaS2sAdapter"
  );
  const channel = DarwiniaS2sAdapter.attach(msgportAddress);
  console.log(`endpointAddress: ${await channel.endpointAddress()}`);
  return await channel.estimateFee();
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
