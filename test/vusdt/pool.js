'use strict'
const { prepareConfig } = require('./config')
const { shouldBehaveLikePool } = require('../behavior/paycer-pool')
const { shouldBehaveLikeMultiPool } = require('../behavior/paycer-multi-pool')

describe('vUSDT Pool', function () {
  prepareConfig()
  shouldBehaveLikePool('vUSDT', 'USDT')
  shouldBehaveLikeMultiPool('vUSDT')
})
