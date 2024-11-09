// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./hjhsyscombine.sol";  // Import the main contract

contract Reward {

    DepositAndWithdraw public depositContract;

    struct RewardInfo {
        uint256 points;
        uint256 lastDailyLogin;
        uint256 lastWeeklyReward;
        uint256 lastDepositReward;
    }

    mapping(address => RewardInfo) public rewards;

    event DailyLoginReward(address indexed user, uint256 points, uint256 timestamp);
    event WeeklyBalanceReward(address indexed user, uint256 points, uint256 timestamp);
    event CashbackReward(address indexed user, uint256 points, uint256 amount);
    event RewardReminder(address indexed user, string message);
    event PrizesPurchased(address indexed user, string prize, uint256 cost);

    // Rewards settings
    uint256 public constant DAILY_REWARD = 1;
    uint256 public constant DEPOSIT_WITHDRAW_REWARD = 3;
    uint256 public constant MAX_DEPOSIT_REWARD = 10;
    uint256 public constant WEEKLY_BALANCE_REWARD = 5;
    uint256 public constant ETHER_THRESHOLD = 1 ether;

    constructor(address depositAddress) {
        depositContract = DepositAndWithdraw(depositAddress); // Link the main contract
    }

    // Modifier to prevent multiple logins within the same day
    modifier dailyLoginEligible() {
        require(block.timestamp >= rewards[msg.sender].lastDailyLogin + 1 days, "Already claimed daily login reward");
        _;
    }

    // Modifier to ensure deposit rewards only happen once a week
    modifier weeklyDepositRewardEligible() {
        require(block.timestamp >= rewards[msg.sender].lastDepositReward + 7 days, "Weekly deposit reward already claimed");
        _;
    }

    // Function to login and claim daily reward
    function dailyLogin() public dailyLoginEligible {
        rewards[msg.sender].points += DAILY_REWARD;
        rewards[msg.sender].lastDailyLogin = block.timestamp;
        emit DailyLoginReward(msg.sender, DAILY_REWARD, block.timestamp);
    }
/*
    // Check if user has earned their weekly reward based on their balance
    function checkWeeklyBalanceReward() public {
        // Fetch the account struct from the DepositAndWithdraw contract
        DepositAndWithdraw.Account memory account = depositContract.accounts(msg.sender);

        // Access the balance field from the struct
        uint256 accountBalance = account.balance;
        uint256 etherAmount = accountBalance / 1 ether;
        uint256 rewardPoints = etherAmount / 10;

        if (rewardPoints > WEEKLY_BALANCE_REWARD) {
            rewardPoints = WEEKLY_BALANCE_REWARD; // Cap the weekly points
        }

        // Ensure the user has not already claimed this week
        require(block.timestamp >= rewards[msg.sender].lastWeeklyReward + 7 days, "Weekly balance reward already claimed");

        // Add points and update the timestamp
        rewards[msg.sender].points += rewardPoints;
        rewards[msg.sender].lastWeeklyReward = block.timestamp;
        
        emit WeeklyBalanceReward(msg.sender, rewardPoints, block.timestamp);
    }
*/
    // Cashback reward for deposits and withdrawals
    function depositWithdrawCashback(uint256 amount) public weeklyDepositRewardEligible {
        uint256 rewardPoints = DEPOSIT_WITHDRAW_REWARD;
        
        if (amount >= ETHER_THRESHOLD) {
            uint256 extraPoints = amount / 1 ether;  // 1 point per 1 ether
            if (extraPoints > MAX_DEPOSIT_REWARD) {
                extraPoints = MAX_DEPOSIT_REWARD;  // Max 10 points
            }
            rewardPoints += extraPoints;
        }

        // Update rewards and timestamp for weekly deposit
        rewards[msg.sender].points += rewardPoints;
        rewards[msg.sender].lastDepositReward = block.timestamp;

        emit CashbackReward(msg.sender, rewardPoints, amount);
    }

    // Check if a user has received daily and weekly rewards and notify
    function rewardReminder() public {
        if (block.timestamp >= rewards[msg.sender].lastDailyLogin + 1 days) {
            emit RewardReminder(msg.sender, "You have not claimed your daily reward.");
        } else {
            emit RewardReminder(msg.sender, "Daily reward already claimed.");
        }

        if (block.timestamp >= rewards[msg.sender].lastWeeklyReward + 7 days) {
            emit RewardReminder(msg.sender, "You have not claimed your weekly reward.");
        } else {
            emit RewardReminder(msg.sender, "Weekly reward already claimed.");
        }
    }

    // Users can use their points to purchase prizes
    function purchasePrize(string memory prize, uint256 cost) public {
        require(rewards[msg.sender].points >= cost, "Insufficient reward points");
        rewards[msg.sender].points -= cost;
        emit PrizesPurchased(msg.sender, prize, cost);
    }

    // Function to get available prizes
    function getAvailablePrizes() public pure returns (string[3] memory) {
        string[3] memory prizes = ["Gift Card - 50 Points", "Crypto Token - 100 Points", "Free Subscription - 150 Points"];
        return prizes;
    }
}
