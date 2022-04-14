// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.3;

interface IFactory {
    function getPool(uint256) external view returns (address);
}