// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./strategies/Strategy.sol";

struct Action {
    uint8 command;
    uint256 amount;
}

contract TradFiDeFiRouter is KeeperCompatibleInterface, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint8 public constant ACTION_DEPOSIT = 0;
    uint8 public constant ACTION_WITHDRAW = 1;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    Strategy public strategy;
    uint256 public depositThreshold;

    constructor(Strategy _strategy, uint256 _depositThreshold) {
        strategy = _strategy;
        depositThreshold = _depositThreshold;
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestVolumeData() public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        request.add("get", "https://api.paycer.io/api/router/command");

        // Set the path to find the desired data in the API response, where the response format is:
        // {"RAW":
        //   {"ETH":
        //    {"USD":
        //     {
        //      "VOLUME24HOUR": xxx.xxx,
        //     }
        //    }
        //   }
        //  }
        request.add("path", "RAW.ETH.USD.VOLUME24HOUR");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, uint256 _volume) public recordChainlinkFulfillment(_requestId) {
        // TODO generate withdraw action
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    ) external override returns (bool upkeepNeeded, bytes memory performData) {
        // get token balance of router
        IERC20 token = strategy.collateralToken();
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
        Action memory action = abi.decode(performData, (Action));

        // TODO get encoded command from performData
        if (ACTION_DEPOSIT == action.command) {
            IERC20 token = strategy.collateralToken();
            token.approve(address(strategy), action.amount);
            //strategy.pool().deposit(action.amount); // FIXME
        } else if (ACTION_WITHDRAW == action.command) {
            strategy.withdraw(action.amount);
            // TODO send back to bank-managed account
        }
    }
}
