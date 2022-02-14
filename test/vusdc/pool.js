'use strict'
const {prepareConfig} = require('./config')
const {shouldBehaveLikePool} = require('../behavior/paycer-pool')
const {shouldBehaveLikeMultiPool} = require('../behavior/paycer-multi-pool')

describe('vUSDC Pool', function () {
  prepareConfig()
  shouldBehaveLikePool('vUSDC', 'USDC')
  shouldBehaveLikeMultiPool('vUSDC')
})
