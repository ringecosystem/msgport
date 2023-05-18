require("@nomicfoundation/hardhat-toolbox");
require("hardhat-abi-exporter");
require("hardhat-gas-reporter");
require("hardhat-change-network");

require("dotenv").config({ path: ".env" });

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const MAINNET_RPC_URL = process.env.MAINNET_RPC_URL;
const GOERLI_RPC_URL = process.env.GOERLI_RPC_URL;

task(
  "flat",
  "Flattens and prints contracts and their dependencies (Resolves licenses)"
)
  .addOptionalVariadicPositionalParam(
    "files",
    "The files to flatten",
    undefined,
    types.inputFile
  )
  .setAction(async ({ files }, hre) => {
    let flattened = await hre.run("flatten:get-flattened-sources", { files });

    // Remove every line started with "// SPDX-License-Identifier:"
    flattened = flattened.replace(
      /SPDX-License-Identifier:/gm,
      "License-Identifier:"
    );
    flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`;

    // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
    flattened = flattened.replace(
      /pragma experimental ABIEncoderV2;\n/gm,
      (
        (i) => (m) =>
          !i++ ? m : ""
      )(0)
    );
    console.log(flattened);
  });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.9",
        settings: {
          evmVersion: "istanbul",
          optimizer: {
            enabled: true,
            runs: 999999,
          },
          outputSelection: {
            "*": {
              "*": [
                "abi",
                "devdoc",
                "metadata",
                "evm.bytecode.object",
                "evm.bytecode.sourceMap",
                "evm.deployedBytecode.object",
                "evm.deployedBytecode.sourceMap",
                "evm.methodIdentifiers",
              ],
              "": ["ast"],
            },
          },
        },
      },
    ],
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    dev: {
      url: "http://localhost:8545/",
      network_id: "*",
      accounts: [PRIVATE_KEY],
    },
    pangoro: {
      url: "https://pangoro-rpc.darwinia.network",
      network_id: "45",
      accounts: [PRIVATE_KEY],
      gas: 3_000_000,
      gasPrice: 2457757432886,
    },
    pangolin: {
      url: "https://pangolin-rpc.darwinia.network",
      network_id: "43",
      accounts: [PRIVATE_KEY],
      gas: 3_000_000,
      gasPrice: 2457757432886,
    },
    moonbase: {
      url: "https://rpc.api.moonbase.moonbeam.network",
      network_id: "1287",
      accounts: [PRIVATE_KEY],
      gas: 3_000_000,
      gasPrice: 2457757432886,
    },
    pangolinDev: {
      url: "http://g2.dev.darwinia.network:8888",
      network_id: "43",
      accounts: [PRIVATE_KEY],
      gas: 3_000_000,
      gasPrice: 2457757432886,
    },
    crab: {
      url: "https://crab-rpc.darwinia.network",
      network_id: "44",
      accounts: [PRIVATE_KEY],
      gas: 3_000_000,
      gasPrice: 53_100_000_000,
    },
    goerli: {
      url: GOERLI_RPC_URL,
      network_id: "*",
      accounts: [PRIVATE_KEY],
      timeout: 100000,
    },
    mainnet: {
      url: MAINNET_RPC_URL,
      network_id: "1",
      gasPrice: 53100000000,
      accounts: [PRIVATE_KEY],
      timeout: 1000000,
    },
    bnbChainTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      network_id: "97",
      accounts: [PRIVATE_KEY],
    },
    fantomTestnet: {
      url: "https://rpc.testnet.fantom.network",
      network_id: "4002",
      accounts: [PRIVATE_KEY],
    },
    polygonTestnet: {
      url: "https://polygon-testnet.public.blastapi.io",
      network_id: "80001",
      accounts: [PRIVATE_KEY],
    },
    moonbaseAlpha: {
      url: "https://rpc.testnet.moonbeam.network",
      network_id: "1287",
      accounts: [PRIVATE_KEY],
    },
    zkSyncEraTestnet: {
      url: "https://testnet.era.zksync.dev",
      network_id: "280",
      accounts: [PRIVATE_KEY],
    },
    baseGoerliTestnet: {
      url: "https://goerli.base.org",
      network_id: "84531",
      accounts: [PRIVATE_KEY],
    },
    fantom: {
      url: "https://1rpc.io/ftm",
      network_id: "250",
      accounts: [PRIVATE_KEY],
    },
    polygon: {
      url: "https://1rpc.io/matic",
      network_id: "137",
      accounts: [PRIVATE_KEY],
    },
    zkSyncEra: {
      url: "https://mainnet.era.zksync.io",
      network_id: "324",
      accounts: [PRIVATE_KEY],
    },
    bnbChain: {
      url: "https://bsc-dataseed1.defibit.io",
      network_id: "56",
      accounts: [PRIVATE_KEY],
    },
  },
  abiExporter: {
    path: "./abi/",
    clear: false,
    flat: false,
    only: [],
  },
};
