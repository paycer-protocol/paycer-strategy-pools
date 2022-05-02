// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "../Strategy.sol";
import "../../interfaces/stargate/ILPStaking.sol";
import "../../interfaces/stargate/IStargateRouter.sol";
import "../../interfaces/stargate/IFactory.sol";
import "../../interfaces/stargate/IPool.sol";
import "../../interfaces/stargate/IStargateRouter.sol";

// Add liquidity to one of pools .e.g USDT on polygon. Call addLiquidity of Router
// https://polygonscan.com/tx/0x3542cfff6c54ce8a734c61d887744eb0ecc98bc60806f6a548f1fdbe7d46135b
// Function: addLiquidity(uint256 _poolId, uint256 _amountLD, address _to)
// We get Stargate USDT in return.
// Go to farming, approve and stake Stargate USDT. Call deposit of LPStaking
// https://polygonscan.com/tx/0x2f1927bc721032461701e6c696c661781ebbcbe6306061289901d10c2e048da8
// Function: deposit(uint256 _pid, uint256 _amount)

/// @title This strategy will deposit collateral token in stargate pools and earn interest.
abstract contract StargateStrategy is Strategy {
    using SafeERC20 for IERC20;

    uint256 internal stakingPoolId;
    uint16 internal farmingPoolId;
    IStargateRouter internal router;
    ILPStaking internal lpStaking;
    IERC20 internal sToken;
    address internal STG;

    constructor(
        address _pool,
        address _swapManager,
        address _receiptToken,
        uint256 _stakingPoolId,
        uint16 _farmingPoolId,
        address _router,
        address _lpStaking,
        address _STG
    ) Strategy(_pool, _swapManager, _receiptToken) {
        require(_receiptToken != address(0), "sToken-address-is-zero");
        sToken = IERC20(_receiptToken);
        swapSlippage = 10000;

        stakingPoolId = _stakingPoolId;
        farmingPoolId = _farmingPoolId;
        router = IStargateRouter(_router);
        lpStaking = ILPStaking(_lpStaking);
        STG = _STG;
    }

    /**
     * @notice Calculate total value using STG accrued and sToken
     * @dev Report total value in collateral token
     */
    function totalValue() public view virtual override returns (uint256 _totalValue) {
        _totalValue = _calculateTotalValue(lpStaking.pendingStargate(stakingPoolId, address(this)));
    }

    function totalValueCurrent() external virtual override returns (uint256 _totalValue) {
        _claimSTG();
        _totalValue = _calculateTotalValue(IERC20(STG).balanceOf(address(this)));
    }

    function _calculateTotalValue(uint256 _stgAccrued) internal view returns (uint256 _totalValue) {
        if (_stgAccrued != 0) {
            (, _totalValue) = swapManager.bestPathFixedInput(STG, address(collateralToken), _stgAccrued, 0);
        }
        _totalValue += _convertToCollateral(sToken.balanceOf(address(this)));
    }

    function isReservedToken(address _token) public view virtual override returns (bool) {
        return _token == address(sToken) || _token == address(STG);
    }

    /// @notice Approve all required tokens
    function _approveToken(uint256 _amount) internal virtual override {
        collateralToken.safeApprove(pool, _amount);
        collateralToken.safeApprove(address(sToken), _amount);
        for (uint256 i = 0; i < swapManager.N_DEX(); i++) {
            IERC20(STG).safeApprove(address(swapManager.ROUTERS(i)), _amount);
        }
    }

    /**
     * @notice Claim STG and transfer to new strategy
     * @param _newStrategy Address of new strategy.
     */
    function _beforeMigration(address _newStrategy) internal virtual override {
        _claimSTG();
        IERC20(STG).safeTransfer(_newStrategy, IERC20(STG).balanceOf(address(this)));
    }

    /// @notice Claim stargate
    function _claimSTG() internal {
        lpStaking.deposit(stakingPoolId, 0);
    }

    /// @notice Claim STG and convert STG into collateral token.
    function _claimRewardsAndConvertTo(address _toToken) internal virtual override {
        _claimSTG();
        uint256 _stgAmount = IERC20(STG).balanceOf(address(this));
        if (_stgAmount != 0) {
            uint256 minAmtOut =
                (swapSlippage != 10000)
                    ? _calcAmtOutAfterSlippage(
                        _getOracleRate(_simpleOraclePath(STG, _toToken), _stgAmount),
                        swapSlippage
                    )
                    : 1;
            _safeSwap(STG, _toToken, _stgAmount, minAmtOut);
        }
    }

    /// @notice Withdraw collateral to payback excess debt
    function _liquidate(uint256 _excessDebt) internal override returns (uint256 _payback) {
        if (_excessDebt != 0) {
            _payback = _safeWithdraw(_excessDebt);
        }
    }

    /**
     * @notice Calculate earning and withdraw it from Compound.
     * @dev Claim STG and convert into collateral
     * @dev If somehow we got some collateral token in strategy then we want to
     *  include those in profit. That's why we used 'return' outside 'if' condition.
     * @param _totalDebt Total collateral debt of this strategy
     * @return profit in collateral token
     */
    function _realizeProfit(uint256 _totalDebt) internal virtual override returns (uint256) {
        _claimRewardsAndConvertTo(address(collateralToken));
        uint256 _collateralBalance = _convertToCollateral(sToken.balanceOf(address(this)));
        if (_collateralBalance > _totalDebt) {
            _withdrawHere(_collateralBalance - _totalDebt);
        }
        return collateralToken.balanceOf(address(this));
    }

    /**
     * @notice Calculate realized loss.
     * @return _loss Realized loss in collateral token
     */
    function _realizeLoss(uint256 _totalDebt) internal view override returns (uint256 _loss) {
        uint256 _collateralBalance = _convertToCollateral(sToken.balanceOf(address(this)));
        if (_collateralBalance < _totalDebt) {
            _loss = _totalDebt - _collateralBalance;
        }
    }

    /// @notice Deposit collateral in Stargate
    function _reinvest() internal virtual override {
        uint256 _collateralBalance = collateralToken.balanceOf(address(this));
        if (_collateralBalance != 0) {
            collateralToken.safeApprove(address(lpStaking), _collateralBalance);
            router.addLiquidity(farmingPoolId, _collateralBalance, address(this));
            sToken.safeApprove(address(lpStaking), sToken.balanceOf(address(this)));
            lpStaking.deposit(stakingPoolId, _collateralBalance);
        }
    }

    /// @dev Withdraw collateral and transfer it to pool
    function _withdraw(uint256 _amount) internal override {
        _safeWithdraw(_amount);
        collateralToken.safeTransfer(pool, collateralToken.balanceOf(address(this)));
    }

    /**
     * @notice Safe withdraw will make sure to check asking amount against available amount.
     * @param _amount Amount of collateral to withdraw.
     * @return Actual collateral withdrawn
     */
    function _safeWithdraw(uint256 _amount) internal returns (uint256) {
        (uint256 amount,) = lpStaking.userInfo(stakingPoolId, address(this));
        uint256 _collateralBalance = _convertToCollateral(amount);
        return _withdrawHere(_amount < _collateralBalance ? _amount : _collateralBalance);
    }

    /// @dev Withdraw collateral here. Do not transfer to pool
    function _withdrawHere(uint256 _amount) internal returns (uint256) {
        if (_amount != 0) {
            IPool pool = IPool(IFactory(router.factory()).getPool(farmingPoolId));
            uint256 _amountSToken = _amount * pool.totalSupply() / pool.totalLiquidity() / pool.convertRate();
            lpStaking.withdraw(stakingPoolId, _amountSToken);
            require(router.instantRedeemLocal(farmingPoolId, _amountSToken, address(this)) == 0, "withdraw-from-compound-failed");
            _afterRedeem();
        }
        return _amount;
    }

    function _setupOracles() internal virtual override {
        swapManager.createOrUpdateOracle(STG, WETH, oraclePeriod, oracleRouterIdx);
        if (address(collateralToken) != WETH) {
            swapManager.createOrUpdateOracle(WETH, address(collateralToken), oraclePeriod, oracleRouterIdx);
        }
    }

    /**
     * @dev Compound support ETH as collateral not WETH. This hook will take
     * care of conversion from WETH to ETH and vice versa.
     * @dev This will be used in ETH strategy only, hence empty implementation
     */
    //solhint-disable-next-line no-empty-blocks
    function _afterRedeem() internal virtual {}

    function _convertToCollateral(uint256 _sTokenAmount) internal view returns (uint256) {
        IPool pool = IPool(IFactory(router.factory()).getPool(farmingPoolId));
        return _sTokenAmount * pool.totalLiquidity()  * pool.convertRate() / pool.totalSupply();
    }
}