// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./InterfaceCombine.sol"; // Import the interface
contract InterestModule {

    IDepositAndWithdraw public interfaceDepositAndWithdraw;

    constructor(address _depositAndWithdrawAddress)  payable {
        interfaceDepositAndWithdraw = IDepositAndWithdraw(_depositAndWithdrawAddress);
    }

    //InterestModule Yew Wen Kang
    //Variable Declaration
    uint256 public monthlyInterestRate = 2; // 2% for monthly
    uint256 public yearlyInterestRate = 3; // 3% for yearly
    uint256 public testingInterestRate = 1; // 1% for testing

    uint256 public constant MONTHLY_INTERVAL = 30 * 24 * 60 * 60; // 30 days in seconds 2,592,000 2592000
    uint256 public constant YEARLY_INTERVAL = 365 * 24 * 60 * 60; // 365 days in seconds 31,536,000 31536000
    uint256 public constant TESTING_INTERVAL = 30; // Set the interval to 30 seconds for testing
    uint256 public constant yearIn30Seconds = YEARLY_INTERVAL / TESTING_INTERVAL; //1,051,200 1051200

    struct InterestHistory {
        uint256 timestamp;   // When the interest action happened
        uint256 interestAmount; // The amount of interest withdrawn or distributed or add
        address recipient;   // The account that received the interest (for distribution)
    }

    mapping(address => uint256) public accountBalances; // User balances
    mapping(address => uint256) public accountInterestRates; // Interest rates per account
    mapping(address => uint256) public lastInterestCalculationTime; // Last interest calculation time per account
    mapping(address => uint256) public userAccrualIntervals; // Accrual interval per account
    mapping(address => InterestHistory[]) public withdrawalHistory; // Mapping for interest withdrawal history per user
    mapping(address => InterestHistory[]) public distributionHistory; // Mapping for interest distribution history per user
    mapping(address => InterestHistory[]) public addInterestHistory; // Mapping for add interest history per user

    event InterestAdd(uint256 interestAmount, address account);
    event InterestWithdrawn(uint256 interestAmount, address to);
    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);
    event AccrualIntervalChanged(address indexed account, uint256 newInterval);

    //Modifier
    //Ensure the interest time is reach
    modifier onlyReachInterval(address account) {
        require(block.timestamp >= lastInterestCalculationTime[account] + userAccrualIntervals[account], "Accrual interval has not been reached yet");
        _;
    }

    //Ensure user balance in contract is enough
    // modifier sufficientBalance(uint256 amount,address account) {
    //     require(accountBalances[account] >= amount, "Insufficient balance");
    //     _;
    // }

    //Ensure amount is positive
    modifier positiveAmount(uint256 amount) {
        require(amount > 0, "Amount must be greater than zero");
        _;
    }

    //Ensure the interval is valid
    modifier validInterval(uint256 newInterval){
        require(newInterval == MONTHLY_INTERVAL || newInterval == YEARLY_INTERVAL || newInterval == TESTING_INTERVAL,"Invalid interval. Must be either monthly or yearly or Testing.");
        _;
    }

    


    // Calculator for interest, input amount, time, rate, show the interest for testing, month , year
    // timeElapsedInSeconds is how long you want to put your balance
    function interestCalculator(uint256 amount, uint256 startEpoch, uint256 endEpoch) public view returns (uint256 ,uint256 ,uint256) {
        require(amount > 0, "Amount must be greater than zero");

        //For testing
        uint256 testingIntervalPassed = (endEpoch - startEpoch) / TESTING_INTERVAL; //Pass how many 30 seconds


        //For month
        uint256 monthIntervalPassed = (endEpoch - startEpoch) / MONTHLY_INTERVAL;

        //For year
        uint256 yearIntervalPassed = (endEpoch - startEpoch) / YEARLY_INTERVAL;

        //Calculate Interest for testing 
        uint256 interestTest = (amount * testingInterestRate / 100 * testingIntervalPassed) / yearIn30Seconds; //pass 1 get 9,512,937,595 if 1 ether
        uint256 interestMonth = (amount * monthlyInterestRate / 100 * monthIntervalPassed) / 12; //1 year = 12 months
        uint256 interestYear = (amount * yearlyInterestRate / 100 * yearIntervalPassed); //in year no need
         
        return (interestTest,interestMonth,interestYear);
    }


    //-----------------------------
    // Deposit ether into the contract  (Remove after combine, check before remove)
    function deposit(uint256 value,address account) public positiveAmount(value) payable {

        accountBalances[account] += value;

        // If first deposit, set the last interest calculation time and default interval
        if (lastInterestCalculationTime[account] == 0) {
            lastInterestCalculationTime[account] = block.timestamp;
            userAccrualIntervals[account] = TESTING_INTERVAL; // Default should be monthly but testing for test
            accountInterestRates[account] = testingInterestRate;
        }

        emit Deposit(account, value);
    }

     function updateLastInterestCalculationTime(address account) public payable {
        // If first deposit, set the last interest calculation time and default interval
        if (lastInterestCalculationTime[account] == 0) {
            lastInterestCalculationTime[account] = block.timestamp;
            userAccrualIntervals[account] = TESTING_INTERVAL; // Default should be monthly but testing for test
            accountInterestRates[account] = testingInterestRate;
        }
    }




    // Calculate interest for a specific account with a time lock
    function calculateInterest(address account,uint256 balance) public view onlyReachInterval(account) returns (uint256){
        uint256 interest;
        uint256 timeElapsed = block.timestamp - lastInterestCalculationTime[account]; //Second Passed correct

        //For testing
        uint256 testingIntervalPassed = timeElapsed / TESTING_INTERVAL; //Pass how many 30 seconds

        //For month
        uint256 monthIntervalPassed = timeElapsed / MONTHLY_INTERVAL;

        //For year
        uint256 yearIntervalPassed = timeElapsed / YEARLY_INTERVAL;

        //Calculate Interest for testing 
        if(userAccrualIntervals[account] == TESTING_INTERVAL){
            interest = (balance * accountInterestRates[account] / 100 * testingIntervalPassed) / yearIn30Seconds; //pass 1 get 9,512,937,595 if 1 ether
        }else if(userAccrualIntervals[account] == MONTHLY_INTERVAL){
            interest = (balance * accountInterestRates[account] / 100 * monthIntervalPassed) / 12; //1 year = 12 months
        }else if(userAccrualIntervals[account] == YEARLY_INTERVAL){
            interest = (balance * accountInterestRates[account] / 100 * yearIntervalPassed); //in year no need
        }

        return interest;
    }

    // Add interest to the balance
    function addInterest(address account) public onlyReachInterval(account) returns (uint256) {
        uint256 balance = getAccountBalances(account);
        // setFirstDeposit(account);//if no last time deposit , set current time
        uint256 interest = calculateInterest(account,balance);
        require(interest > 0, "No interest to add");

        //Add at js
        // accountBalances[account] += interest;
        lastInterestCalculationTime[account] = block.timestamp; // Update the last calculation time for the specific account
        
        // Save addInterest history
        addInterestHistory[account].push(
            InterestHistory({
                timestamp: block.timestamp,
                interestAmount: interest,
                recipient: account
            })
        );

        emit InterestAdd(interest, account);
        return interest;
    }

    // Allow users to change their accrual interval (monthly or yearly or testing) 
    function setUserAccrualInterval(uint256 newInterval , address account) public validInterval(newInterval) {
        userAccrualIntervals[account] = newInterval;//change rate also
        if(newInterval == MONTHLY_INTERVAL){
            accountInterestRates[account] = monthlyInterestRate;
        }else if(newInterval == YEARLY_INTERVAL){
            accountInterestRates[account] = yearlyInterestRate;
        }else if(newInterval == TESTING_INTERVAL){
            accountInterestRates[account] = testingInterestRate;
        }
        
        emit AccrualIntervalChanged(account, newInterval);
    }

    function getUserAccrualInterval(address account) public view returns (uint256) {
        return userAccrualIntervals[account];
    }

    function getAccountInterestRates(address account) public view returns (uint256) {
        return accountInterestRates[account];
    }


    // Withdraw accrued interest and reset interest calculation
    function withdrawInterest(address account) public onlyReachInterval(account) returns (uint256)  {
        uint256 balance = getAccountBalances(account);
        uint256 interest = calculateInterest(account,balance);
        require(interest > 0, "No interest available to withdraw");

        // Add to withdrawal history
        withdrawalHistory[account].push(
            InterestHistory({
                timestamp: block.timestamp,
                interestAmount: interest,
                recipient: account
            })
        );

        //payable(account).transfer(10);//Remove
        emit InterestWithdrawn(interest, account);
        return interest;
    }

    // Distribute a percentage of interest to a specific account in a single transaction
    // function distributeInterest(uint256 percentage, address toAccount, address fromAccount,uint256 balance) public onlyReachInterval(fromAccount) returns (bool) {
    //     require(percentage > 0 && percentage <= 100, "Invalid percentage value"); // Ensure percentage is between 0 and 100
    //     require(toAccount != address(0), "Invalid address"); // Ensure a valid account address

    //     uint interest = calculateInterest(fromAccount,balance);

    //     uint256 interestDistributed = (interest * percentage) / 100; // Calculate interest to distribute
    //     uint256 interestWithdraw = interest - interestDistributed; //Remain interest withdraw

    //     //accountBalances[fromAccount] -= interest; //Deduct the balance

    //     //payable(toAccount).transfer(interestDistributed); // Transfer the calculated interest to the account
    //     emit InterestWithdrawn(interestDistributed, toAccount); // Emit the event for interest distribution

    //     //payable(fromAccount).transfer(interestWithdraw); // Withdraw the remain interest
    //     emit InterestWithdrawn(interestWithdraw, fromAccount); // Emit the event for interest withdraw

    //     // Add to distribution history for both sender and recipient
    //     distributionHistory[fromAccount].push(
    //         InterestHistory({
    //             timestamp: block.timestamp,
    //             interestAmount: interestDistributed,
    //             recipient: toAccount
    //         })
    //     );

    //     withdrawalHistory[fromAccount].push(
    //         InterestHistory({
    //             timestamp: block.timestamp,
    //             interestAmount: interestWithdraw,
    //             recipient: fromAccount
    //         })
    //     );
    //     return true;
    // }

    function distributeInterest(uint256 percentage, address toAccount, address fromAccount) public onlyReachInterval(fromAccount) returns (uint256 interestDistributed, uint256 interestWithdraw) 
    {
        uint256 balance = getAccountBalances(fromAccount);
        require(percentage > 0 && percentage <= 100, "Invalid percentage value"); // Ensure percentage is between 0 and 100
        require(toAccount != address(0), "Invalid address"); // Ensure a valid account address

        uint interest = calculateInterest(fromAccount, balance);

        interestDistributed = (interest * percentage) / 100; // Calculate interest to distribute
        interestWithdraw = interest - interestDistributed; // Remain interest withdraw

        //accountBalances[fromAccount] -= interest; // Deduct the balance

        //payable(toAccount).transfer(interestDistributed); // Transfer the calculated interest to the account
        emit InterestWithdrawn(interestDistributed, toAccount); // Emit the event for interest distribution

        //payable(fromAccount).transfer(interestWithdraw); // Withdraw the remain interest
        emit InterestWithdrawn(interestWithdraw, fromAccount); // Emit the event for interest withdraw

        // Add to distribution history for both sender and recipient
        distributionHistory[fromAccount].push(
            InterestHistory({
                timestamp: block.timestamp,
                interestAmount: interestDistributed,
                recipient: toAccount
            })
        );

        withdrawalHistory[fromAccount].push(
            InterestHistory({
                timestamp: block.timestamp,
                interestAmount: interestWithdraw,
                recipient: fromAccount
            })
        );

        return (interestDistributed, interestWithdraw);
    }


    // Fallback function to accept Ether into the contract
    receive() external payable {}

    // Helper function to check contract balance (for testing) (Remove after combine)
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to show the current block timestamp
    function getCurrentBlockTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    // Get withdrawal history for a user
    function getWithdrawalHistory(address user) public view returns (InterestHistory[] memory) {
        return withdrawalHistory[user];
    }

    // Get distribution history for a user
    function getDistributionHistory(address user) public view returns (InterestHistory[] memory) {
        return distributionHistory[user];
    }

    // Get add interest history for a user
    function getAddInterestHistory(address user) public view returns (InterestHistory[] memory) {
        return addInterestHistory[user];
    }

    // Function to get the balance of another contract
    function getOtherContractBalance(address contractAddress) public view returns (uint256) {
        return contractAddress.balance;
    }

    function testAccount(address account) public pure returns (address) {
        return account;
    }

    // function getAccountBalances(address account) public view returns (uint256) {
    //     return accountBalances[account];
    // }

    function getLastInterestCalculationTime(address account) public view returns (uint256) {
        return lastInterestCalculationTime[account];
    }

    //Use this two together
    // Access the account balance via the interface
    function getAccountBalances(address account) public view returns (uint256) {
        (uint256 balance, , , , ) = interfaceDepositAndWithdraw.accounts(account);
        // setFirstDeposit(account);
        return balance;
    }

    function setFirstDeposit(address account) public {
        // If first deposit, set the last interest calculation time and default interval
        if (lastInterestCalculationTime[account] == 0) {
            lastInterestCalculationTime[account] = block.timestamp;
            userAccrualIntervals[account] = TESTING_INTERVAL; // Default should be monthly but testing for test
            accountInterestRates[account] = testingInterestRate;
        }
    }
}
