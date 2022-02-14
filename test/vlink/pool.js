'use strict'

const {prepareConfig} = require('./config')
const {shouldBehaveLikePool} = require('../behavior/paycer-pool')
const {shouldBehaveLikeMultiPool} = require('../behavior/paycer-multi-pool')

// Note: Skipping since vLIKE uses C.R.E.A.M. strategy
// See more: https://github.com/bloqpriv/paycer-pools-v3/issues/600
describe.skip('vLINK Pool', function () {
  prepareConfig()
  shouldBehaveLikePool('vLINK', 'LINK')
  shouldBehaveLikeMultiPool('vLINK')
})
