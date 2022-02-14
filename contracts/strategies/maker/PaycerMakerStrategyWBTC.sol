// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "./PaycerMakerStrategy.sol";

//solhint-disable no-empty-blocks
contract PaycerMakerStrategyWBTC is PaycerMakerStrategy {
    string public constant NAME = "Paycer-Maker-Strategy-WBTC";
    string public constant VERSION = "3.0.16";

    constructor(
        address _pool,
        address _cm,
        address _swapManager,
        address _vPool
    ) PaycerMakerStrategy(_pool, _cm, _swapManager, _vPool, "WBTC-A") {}

    function convertFrom18(uint256 amount) public pure virtual override returns (uint256) {
        return amount / (10**10);
    }
}
