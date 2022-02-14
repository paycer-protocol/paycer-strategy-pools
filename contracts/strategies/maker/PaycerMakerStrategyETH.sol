// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "./PaycerMakerStrategy.sol";

//solhint-disable no-empty-blocks
contract PaycerMakerStrategyETH is PaycerMakerStrategy {
    string public constant NAME = "Paycer-Maker-Strategy-ETH";
    string public constant VERSION = "3.0.16";

    constructor(
        address _pool,
        address _cm,
        address _swapManager,
        address _vPool
    ) PaycerMakerStrategy(_pool, _cm, _swapManager, _vPool, "ETH-C") {}
}
