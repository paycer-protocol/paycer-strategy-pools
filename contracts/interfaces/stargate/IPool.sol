// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.3;


interface IPool {
    function totalLiquidity() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function convertRate() external view returns (uint256);
}