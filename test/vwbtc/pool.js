'use strict'
const { prepareConfig } = require('./config')
const { shouldBehaveLikePool } = require('../behavior/paycer-pool')
const { shouldBehaveLikeMultiPool } = require('../behavior/paycer-multi-pool')

describe('vWBTC Pool', function () {
  prepareConfig()
  shouldBehaveLikePool('vWBTC', 'WBTC')
  shouldBehaveLikeMultiPool('vWBTC')
})
