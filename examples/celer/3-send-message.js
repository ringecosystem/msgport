const hre = require("hardhat");

async function main() {
  const bscMsgportAddress = "0xE669D751d2C79EA11a947aDE15eFb2720D7a6F94"; // process.argv[2];

  // deploy the msg receiver on fantom
  hre.changeNetwork("fantomTestnet");
  FantomDapp = await hre.ethers.getContractFactory("FantomDapp");
  const fantomDapp = await FantomDapp.deploy();
  await fantomDapp.deployed();
  console.log(` fantomDapp: ${fantomDapp.address}`);

  const fromDappAddress = "0xD93E82b9969CC9a016Bc58f5D1D7f83918fd9C79";
  const toDappAddress = fantomDapp.address;
  const messagePayload = "0x12345678";
  const executionGas = 0;
  const gasPrice = 0;

  hre.changeNetwork("bscTestnet");
  let DefaultMsgport = await hre.ethers.getContractFactory("DefaultMsgport");
  const bscMsgport = await DefaultMsgport.attach(bscMsgportAddress);

  const fee = await bscMsgport.estimateFee(
    fromDappAddress,
    toDappAddress,
    messagePayload,
    executionGas,
    gasPrice
  );

  console.log(` celer fee: ${fee}`);

  const tx = await bscMsgport.send(
    toDappAddress,
    messagePayload,
    executionGas,
    gasPrice,
    { value: fee }
  );

  console.log(
    `https://testnet.bscscan.com/tx/${(await tx.wait()).transactionHash}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
