// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

interface IFactory {
    function getPool(uint256) external view returns (address);
}