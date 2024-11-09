// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./latestCombine.sol";

/*
import "./account.sol"; // Importing Account contract
import "./Trackmodule2.0.sol"; // Importing Transaction contract
import "./DepositAndWithdrawals.sol"; // Importing DepositAndWithdraw contract
*/
contract RewardSystem {
    DepositAndWithdraw public accountContract;
    DepositAndWithdraw public transactionContract;
    DepositAndWithdraw public depositContract;

    struct UserRewards {
        uint256 totalPoints;
        uint256 lastDailyLogin; // timestamp for the last daily login reward
        uint256 lastWeeklyReward; // timestamp for the last weekly reward from deposit/withdraw
    }

    mapping(address => UserRewards) public userRewards;
    uint256 constant DAILY_REWARD = 1; // 1 point for daily login
    uint256 constant WEEKLY_REWARD_BASE = 3; // 3 points for deposit/withdraw
    uint256 constant MAX_ETH_REWARD = 10 ether; // Max 10 points for 10 Ether
    uint256 constant ONE_WEEK = 7 days;
    uint256 constant ONE_DAY = 1 days;

    // Events
    event DailyRewardClaimed(
        address indexed user,
        uint256 points,
        uint256 timestamp
    );
    event WeeklyRewardClaimed(
        address indexed user,
        uint256 points,
        uint256 timestamp
    );
    event PrizePurchased(
        address indexed user,
        string prize,
        uint256 pointsSpent,
        uint256 timestamp
    );
    event RewardReminder(
        address indexed user,
        string message,
        uint256 timestamp
    );

   constructor(
        address _accountAddress,
        address _transactionAddress,
        address _depositAddress,
        address _accountContractAddress
    ) {
        accountContract = DepositAndWithdraw(_accountAddress);
        transactionContract = DepositAndWithdraw(_transactionAddress);
        depositContract = DepositAndWithdraw(_depositAddress);
        accountContract = DepositAndWithdraw(_accountContractAddress);
    }


    modifier userExists() {
        // Fetch the user details from the Account contract
        (address account, , , , , , , ) = accountContract.getUser(msg.sender);
        require(account != address(0), "User does not exist");
        _;
    }

    // Modifier to ensure enough reward points
    modifier hasSufficientPoints(uint256 _points) {
        require(
            userRewards[msg.sender].totalPoints >= _points,
            "Insufficient reward points"
        );
        _;
    }

    // 1. Daily Check-in Reward
    function checkInDaily() external userExists {
        UserRewards storage rewards = userRewards[msg.sender];
        require(
            block.timestamp >= rewards.lastDailyLogin + ONE_DAY,
            "Daily reward already claimed"
        );

        rewards.totalPoints += DAILY_REWARD;
        rewards.lastDailyLogin = block.timestamp;

        emit DailyRewardClaimed(msg.sender, DAILY_REWARD, block.timestamp);
    }

    // 2. Weekly Reward on Deposit/Withdrawal
    function processWeeklyReward(address _user, uint256 _amount) internal {
        UserRewards storage rewards = userRewards[_user];
        require(
            block.timestamp >= rewards.lastWeeklyReward + ONE_WEEK,
            "Weekly reward already claimed"
        );

        // Base weekly reward of 3 points for a deposit or withdrawal
        uint256 points = WEEKLY_REWARD_BASE;

        // Additional points based on the amount deposited/withdrawn
        uint256 extraPoints = _amount / 1 ether; // 1 point per Ether
        if (extraPoints > 10) {
            extraPoints = 10; // Maximum of 10 points
        }

        points += extraPoints;

        rewards.totalPoints += points;
        rewards.lastWeeklyReward = block.timestamp;

        emit WeeklyRewardClaimed(_user, points, block.timestamp);
    }

    // Function to track deposits and withdrawals and trigger rewards
    function onFundsDeposit(address _user, uint256 _amount) external {
        processWeeklyReward(_user, _amount);
    }

    function onFundsWithdrawal(address _user, uint256 _amount) external {
        processWeeklyReward(_user, _amount);
    }

    // 3. Reminder if daily or weekly reward is claimed
    function checkRewardStatus() external userExists {
        string memory dailyMsg = block.timestamp >=
            userRewards[msg.sender].lastDailyLogin + ONE_DAY
            ? "You can claim your daily reward!"
            : "Daily reward already claimed!";

        string memory weeklyMsg = block.timestamp >=
            userRewards[msg.sender].lastWeeklyReward + ONE_WEEK
            ? "You can claim your weekly reward!"
            : "Weekly reward already claimed!";

        emit RewardReminder(
            msg.sender,
            string(abi.encodePacked(dailyMsg, " ", weeklyMsg)),
            block.timestamp
        );
    }

    // 4. Redeem rewards for prizes
    function redeemPrize(uint256 _points, string calldata _prize)
        external
        userExists
        hasSufficientPoints(_points)
    {
        userRewards[msg.sender].totalPoints -= _points;

        emit PrizePurchased(msg.sender, _prize, _points, block.timestamp);
    }

    // Helper function to check accumulated reward points
    function checkPoints() external view returns (uint256) {
        return userRewards[msg.sender].totalPoints;
    }
}
