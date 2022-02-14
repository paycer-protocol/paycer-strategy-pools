'use strict'

const {prepareConfig} = require('./config')
const {shouldBehaveLikePool} = require('../behavior/paycer-pool')
const {shouldBehaveLikeMultiPool} = require('../behavior/paycer-multi-pool')

describe('vETH Pool', function () {
  prepareConfig()
  shouldBehaveLikePool('vETH', 'WETH')
  shouldBehaveLikeMultiPool('vETH')
})
