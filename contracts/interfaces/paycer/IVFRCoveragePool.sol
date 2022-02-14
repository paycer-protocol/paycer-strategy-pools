// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "./IPaycerPool.sol";

interface IVFRCoveragePool is IPaycerPool {
    function buffer() external view returns (address);
}
