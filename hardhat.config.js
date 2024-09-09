require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.23",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    hardhat: {
    },
    // for mainnet
    mainnet: {
      url: "coming end of February",
      accounts: ['0xPrivateKey'],
      gasPrice: 1000000000,
    },
    // for Sepolia testnet
    blast_sepolia: {
      url: 'https://sepolia.blast.io',
      accounts: ['0xPrivateKey'],
      gasPrice: 1000000000,
    },
  },
  etherscan: {
    apiKey: {
      blast_sepolia: "blast_sepolia", // apiKey is not required, just set a placeholder
    },
    customChains: [
      {
        network: "blast_sepolia",
        chainId: 168587773,
        urls: {
          apiURL: "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
          browserURL: "https://testnet.blastscan.io"
        }
      }
    ]
  },
  defaultNetwork: 'sepolia',
};
