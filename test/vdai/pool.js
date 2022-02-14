'use strict'

const {prepareConfig} = require('./config')
const {shouldBehaveLikePool} = require('../behavior/paycer-pool')
const {shouldBehaveLikeMultiPool} = require('../behavior/paycer-multi-pool')

describe('vDAI Pool', function () {
  
  prepareConfig()
  shouldBehaveLikePool('vDai', 'DAI')
  shouldBehaveLikeMultiPool('vDai')
})
