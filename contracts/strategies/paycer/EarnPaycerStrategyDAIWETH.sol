// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "./EarnPaycerStrategy.sol";

// solhint-disable no-empty-blocks
/// @title Deposit DAI in a Paycer Grow Pool and earn interest in WETH.
contract EarnPaycerStrategyDAIWETH is EarnPaycerStrategy {
    string public constant NAME = "Earn-Paycer-Strategy-DAI-WETH";
    string public constant VERSION = "3.0.15";

    // Strategy will deposit collateral in
    // vaDAI (beta) = 0x0538C8bAc84E95A9dF8aC10Aad17DbE81b9E36ee
    // And collect drip in
    // WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
    constructor(address _pool, address _swapManager)
        EarnPaycerStrategy(
            _pool,
            _swapManager,
            0x0538C8bAc84E95A9dF8aC10Aad17DbE81b9E36ee,
            0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
        )
    {}
}
