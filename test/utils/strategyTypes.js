'use strict'
const StrategyType = {
  AAVE: 'aave',
  AAVE_V1: 'aaveV1',
  ALPHA_LEND: 'alphaLend',
  COMPOUND: 'compound',
  AAVE_MAKER: 'aaveMaker',
  COMPOUND_MAKER: 'compoundMaker',
  PAYCER_MAKER: 'paycerMaker',
  EARN_PAYCER_MAKER: 'earnPaycerMaker',
  CURVE: 'curve',
  CREAM: 'cream',
  YEARN: 'yearn',
  EARN_MAKER: 'earnMaker',
  EARN_COMPOUND: 'earnCompound',
  EARN_CREAM: 'earnCream',
  EARN_AAVE: 'earnAave',
  EARN_RARI_FUSE: 'earnRariFuse',
  EARN_ALPHA_LEND: 'earnAlphaLend',
  EARN_YEARN: 'earnYearn',
  EARN_CURVE: 'earnCurve',
  EARN_PAYCER: 'earnPaycer',
  RARI_FUSE: 'rariFuse',
  COMPOUND_XY: 'compoundXY',
  COMPOUND_LEVERAGE: 'compoundLeverage'
}

module.exports = Object.freeze(StrategyType)
