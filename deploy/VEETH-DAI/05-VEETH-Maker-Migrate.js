'use strict'
const VETH = require('../../helper/ethereum/poolConfig').VETHEarn
const Address = require('../../helper/ethereum/address')
const PaycerMakerStrategy = 'EarnPaycerMakerStrategyETH'
const config = {
  feeCollector: Address.FEE_COLLECTOR
}
const deployFunction = async function ({getNamedAccounts, deployments}) {
  const {deploy, execute} = deployments
  const {deployer} = await getNamedAccounts()

  const poolProxy = await deployments.get('VETH')

  const rewardsProxy = await deploy('PaycerEarnDrip', {
    from: deployer,
    log: true,
    // proxy deployment
    proxy: {
      proxyContract: 'OpenZeppelinTransparentProxy',
      viaAdminContract: 'DefaultProxyAdmin',
      execute: {
        init: {
          methodName: 'initialize',
          args: [poolProxy.address, [Address.vaDAI, Address.VSP]],
        },
      },
    },
  })

  await execute(VETH.contractName, {from: deployer, log: true}, 'updatePoolRewards', rewardsProxy.address)
  await execute('PaycerEarnDrip', {from: deployer, log: true}, 'updateGrowToken', Address.vaDAI)

  const oldStrategy = await deployments.get(PaycerMakerStrategy)
  const newStrategy = await deploy(PaycerMakerStrategy, {
    from: deployer,
    log: true,
    args: [poolProxy.address, Address.COLLATERAL_MANAGER,Address.SWAP_MANAGER, Address.vaDAI],
  })
  await execute(PaycerMakerStrategy, {from: deployer, log: true}, 'init', Address.ADDRESS_LIST_FACTORY)
  await execute(PaycerMakerStrategy, {from: deployer, log: true}, 'approveToken')
  await execute(PaycerMakerStrategy, {from: deployer, log: true}, 'updateFeeCollector', config.feeCollector)
  await execute(PaycerMakerStrategy, {from: deployer, log: true}, 'updateBalancingFactor', 250, 225)

  await execute('VETH', {from: deployer, log: true}, 'migrateStrategy', oldStrategy.address, newStrategy.address)
  
  deployFunction.id = 'veETH-reward-strategy-migrate'
  return true
}
module.exports = deployFunction
module.exports.tags = ['veETH-reward-strategy-migrate']
