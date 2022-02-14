// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "./IPaycerPool.sol";

interface IVFRStablePool is IPaycerPool {
    function targetAPY() external view returns (uint256);

    function buffer() external view returns (address);

    function targetPricePerShare() external view returns (uint256);

    function amountToReachTarget(address _strategy) external view returns (uint256);
}
