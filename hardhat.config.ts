import { HardhatUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-typechain";
import "hardhat-deploy";
import "solidity-coverage";
import { config as dotEnvConfig } from "dotenv";

dotEnvConfig();

const { ETHERSCAN_API_KEY, BASESCAN_API_KEY, INFURA_API_KEY, PRIVATE_KEY_ENV } = process.env;
const PRIVATE_KEY =
  PRIVATE_KEY_ENV ||
  "0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3"; // well known private key

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  solidity: {
    compilers: [
      {
        version: "0.8.19",
      },
    ],
  },
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    base_goreli: {
      url: `https://base-goerli.public.blastapi.io`,
      chainId: 84531,
      accounts: [PRIVATE_KEY],
    },
    base_mainnet: {
      url: `https://base.meowrpc.com`,
      chainId: 8453,
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      url: 'https://ethereum-goerli.publicnode.com',
      chainId: 5,
      accounts: [PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: {
      goerli: ETHERSCAN_API_KEY || "",
      base_mainnet: BASESCAN_API_KEY || "",
    },
    customChains: [
      {
        network: "base_mainnet",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://basescan.org"
        }
      }
    ]
  },
};

export default config;
