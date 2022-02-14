'use strict'

const { prepareConfig } = require('./config')
const { shouldBehaveLikePool } = require('../behavior/paycer-pool')
const { shouldBehaveLikeMultiPool } = require('../behavior/paycer-multi-pool')

describe('vUNI Pool', function () {

  prepareConfig()
  shouldBehaveLikePool('vUni', 'UNI')
  shouldBehaveLikeMultiPool('vUni')
})
