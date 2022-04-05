// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./pool/VPool.sol";

struct Action {
    uint8 command;
    uint256 amount;
    address bankManagedAccount;
}

contract TradFiDeFiRouter is KeeperCompatibleInterface, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint8 public constant ACTION_DEPOSIT = 0;
    uint8 public constant ACTION_WITHDRAW = 1;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    VPool public pool;
    uint256 public depositThreshold;

    constructor(VPool _pool, uint256 _depositThreshold) {
        pool = _pool;
        depositThreshold = _depositThreshold;

        // initialize Chainlink
        setPublicChainlinkToken();
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId = "d5270d1c311941d0b08bead21fea7747";
        fee = 0.1 * 10**18; // (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response
     */
    function requestActionFromAPI() public returns (bytes32 requestId) {
        Chainlink.Request memory request =
            buildChainlinkRequest(jobId, address(this), this.fulfillMultipleParameters.selector);

        // Set the URL to perform the GET request on
        request.add("get", "https://api.paycer.io/api/router/command");

        // TODO check command for correct signature

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /**
     * @notice Fulfillment function for multiple parameters in a single request
     * @dev This is called by the oracle. recordChainlinkFulfillment must be used.
     */
    function fulfillMultipleParameters(
        bytes32 requestId,
        uint8 command,
        uint256 amount,
        address bankManagedAccount
    ) public recordChainlinkFulfillment(requestId) {
        Action memory action = Action({command: command, amount: amount, bankManagedAccount: bankManagedAccount});

        doAction(action);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    ) external override returns (bool upkeepNeeded, bytes memory performData) {
        // get token balance of router
        IERC20 token = pool;
        uint256 balance = token.balanceOf(address(this));

        upkeepNeeded = balance >= depositThreshold;
        if (upkeepNeeded) {
            Action memory action;
            action.command = ACTION_DEPOSIT;
            action.amount = balance;
            performData = abi.encode(action);
            return (upkeepNeeded, performData);
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        // get encoded command from performData
        Action memory action = abi.decode(performData, (Action));

        doAction(action);
    }

    event Deposit(address pool, uint256 amount);

    event Withdraw(address bankManagedAccount, uint256 amount);

    function doAction(Action memory action) internal {
        IERC20 token = pool;
        if (ACTION_DEPOSIT == action.command) {
            token.approve(address(pool), action.amount);
            pool.deposit(action.amount);

            emit Deposit(address(pool), action.amount);
        } else if (ACTION_WITHDRAW == action.command) {
            pool.withdraw(action.amount);
            // send back to bank-managed account
            token.transfer(action.bankManagedAccount, action.amount);

            emit Withdraw(action.bankManagedAccount, action.amount);
        }
    }
}
