// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;
import "../interfaces/paycer/IPaycerPool.sol";

interface IPaycerPoolTest is IPaycerPool {
    function strategies(uint256) external view returns (address);
}
