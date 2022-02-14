'use strict'
require('@nomiclabs/hardhat-waffle')
require('@nomiclabs/hardhat-ethers')
require('solidity-coverage')
require('hardhat-deploy')
require('hardhat-log-remover')
require('hardhat-gas-reporter')
require('dotenv').config()
require('./tasks/create-release')
require('./tasks/deploy-pool')

if (process.env.RUN_CONTRACT_SIZER === 'true') {
  require('hardhat-contract-sizer')
}

module.exports = {
  defaultNetwork: 'hardhat',
  networks: {
    localhost: {
      saveDeployments: true,
    },
    hardhat: {
      initialBaseFeePerGas: 0,
      forking: {
        url: 'https://mainnet.infura.io/v3/e687cba7b033449abeb865f24ef82f83',
        blockNumber: process.env.BLOCK_NUMBER ? parseInt(process.env.BLOCK_NUMBER) : undefined,
      },
      saveDeployments: true,
    },
    mainnet: {
      url: 'https://mainnet.infura.io/v3/e687cba7b033449abeb865f24ef82f83',
      chainId: 1,
      gas: 6700000,
    },
    polygon: {
      url: 'https://mainnet.infura.io/v3/e687cba7b033449abeb865f24ef82f83',
      chainId: 137,
      gas: 11700000,
    },
  },
  paths: {
    deployments: 'deployments',
  },
  namedAccounts: {
    deployer: process.env.DEPLOYER || 0,
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS === 'true',
  },
  solidity: {
    version: '0.8.3',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  mocha: {
    timeout: 200000,
  },
}
