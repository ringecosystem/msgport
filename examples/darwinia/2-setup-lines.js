const { setupLines } = require("../helper");

async function main() {
  const senderChain = "goerli";
  const senderLineRegistryAddress = "0xE7fb517F60dA00e210A43Bdf23f011c3fa508Da7"; // <---- This is the sender lineRegistry address from 1-setup-lineRegistrys.js
  const senderLineName = "DarwiniaLine";
  const senderLineParams = [
    "0x9B5010d562dDF969fbb85bC72222919B699b5F54", // senderOutboundLane
    "0x0F6e081B1054c59559Cf162e82503F3f560cA4AF", // senderInboundLane
    "0x6c73B30a48Bb633DC353ed406384F73dcACcA5C3", // senderFeeMarket
  ];

  const receiverChain = "pangolin";
  const receiverLineRegistryAddress = "0x3f1394274103cdc5ca842aeeC9118c512dea9A4F"; // <---- This is the receiver lineRegistry address from 1-setup-lineRegistrys.js
  const receiverLineName = "DarwiniaLine";
  const receiverLineParams = [
    "0xAbd165DE531d26c229F9E43747a8d683eAD54C6c", // receiverOutboundLane
    "0xB59a893f5115c1Ca737E36365302550074C32023", // receiverInboundLane
    "0x4DBdC9767F03dd078B5a1FC05053Dd0C071Cc005", // receiverFeeMarket
  ];

  await setupLines(
    senderChain,
    senderLineRegistryAddress,
    senderLineName,
    senderLineParams,
    receiverChain,
    receiverLineRegistryAddress,
    receiverLineName,
    receiverLineParams
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
