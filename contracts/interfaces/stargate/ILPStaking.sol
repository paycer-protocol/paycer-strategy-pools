// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.3;

interface ILPStaking {
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    function stargate() external view returns (address);

    function lpBalances(uint256) external view returns (uint256);

    function userInfo(uint256, address) external view returns (UserInfo);

    function pendingStargate(uint256 _pid, address _user) external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

}