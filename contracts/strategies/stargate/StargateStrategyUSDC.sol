// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "./StargateStrategy.sol";

/// @title This strategy will deposit collateral token in stargate pools and earn interest.
contract StargateStrategyUSDC is StargateStrategy {
    string public constant NAME = "Stargate-Strategy-DAI";
    string public constant VERSION = "3.0.0";

    // cDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643
    constructor(address _pool, address _swapManager)
        StargateStrategy(_pool, _swapManager, 0x1205f31718499dBf1fCa446663B532Ef87481fe1, 0, 1, 0x45A01E4e04F14f7A4a6702c74187c5F6222033cd, 0x8731d54E9D02c286767d56ac03e8037C07e01e98, 0x2F6F07CDcf3588944Bf4C42aC74ff24bF56e7590)
    {}

}