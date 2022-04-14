// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

interface ILPStaking {
    function stargate() external view returns (address);

    function lpBalances(uint256) external view returns (uint256);

    function userInfo(uint256, address) external view returns (uint256, uint256);

    function pendingStargate(uint256 _pid, address _user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

}