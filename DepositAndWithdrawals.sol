// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositAndWithdraw {

    struct Account {
        uint256 balance;
        uint256 startTime;
        uint256 contractEndTime; // End time for the contract (e.g. child reaches 18 years old)
        address parent;
        bool isChild;
    }

    struct ScheduledWithdraw {
        address recipient;
        uint256 amount;
        uint256 unlockTime;
        bool active;
    }

    struct Withdrawal {
        uint256 amount;
        uint256 timestamp;
        bool isScheduled; // To track if the withdrawal was scheduled or immediate
    }

    mapping(address => Account) public accounts;
    mapping(address => ScheduledWithdraw[]) public scheduledWithdrawals;
    mapping(address => Withdrawal[]) public withdrawalHistory;

    // Events
    event FundsAdded(address indexed account, uint256 amount);
    event WithdrawalMade(address indexed account, uint256 amount);
    event ScheduledWithdrawCreated(address indexed account, uint256 amount, uint256 unlockTime);
    event ScheduledWithdrawCancelled(address indexed account, uint256 amount, uint256 index);
    event ScheduledWithdrawExecuted(address indexed account, uint256 amount, uint256 index);
    event ChildAccountAdded(address indexed parent, address child);

    // Modifiers
    modifier onlyParent(address _child) {
        require(accounts[_child].parent == msg.sender, "Only parent can perform this action");
        _;
    }

    modifier onlyAdult(address _child) {
        require(block.timestamp >= accounts[_child].contractEndTime, "Child must be over 18 years old");
        _;
    }

    modifier sufficientBalance(address _account, uint256 _amount) {
        require(accounts[_account].balance >= _amount, "Insufficient balance");
        _;
    }

    modifier greaterZero(){
        require(msg.value > 0, "Must be > 0");
        _;
    }

    function getCurrentBlockTimestamp() public view returns (uint256){
        return block.timestamp;
    }

    // Add funds to an account
    function addFunds() external greaterZero payable {
        accounts[msg.sender].balance += msg.value;
    }

    // Check balance of the calling account (msg.sender)
    function checkMyBalance() external view returns (uint256) {
        return accounts[msg.sender].balance;
    }

    // Check remaining time for child account to reach adulthood
    function checkTimeRemaining(address _child) external view returns (uint256) {
        if (block.timestamp >= accounts[_child].contractEndTime) {
            return 0;
        }
        return accounts[_child].contractEndTime - block.timestamp;
    }

    // Withdraw funds (added reentrancy protection)
    function withdraw(uint256 _amount) external sufficientBalance(msg.sender, _amount) onlyAdult(msg.sender) {
        // Effects first
        accounts[msg.sender].balance -= _amount;

        // Log withdrawal into history
        withdrawalHistory[msg.sender].push(Withdrawal({
            amount: _amount,
            timestamp: block.timestamp,
            isScheduled: false
        }));

        // Interactions last
        payable(msg.sender).transfer(_amount);

        emit WithdrawalMade(msg.sender, _amount);
    }

    // Schedule withdrawal (only for child over 18)
    function addScheduleWithdraw(uint256 _amount, uint256 _unlockTime) 
        external 
        onlyAdult(msg.sender) 
        sufficientBalance(msg.sender, _amount) 
    {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");

        // Deduct the amount from the account balance at the time of scheduling
        accounts[msg.sender].balance -= _amount;

        scheduledWithdrawals[msg.sender].push(ScheduledWithdraw({
            recipient: msg.sender,
            amount: _amount,
            unlockTime: _unlockTime,
            active: true
        }));

        emit ScheduledWithdrawCreated(msg.sender, _amount, _unlockTime);
    }


    // Cancel scheduled withdrawal
    function cancelScheduleWithdraw(uint256 _index) external {
        require(_index < scheduledWithdrawals[msg.sender].length, "Invalid withdrawal index");
        ScheduledWithdraw storage scheduledTx = scheduledWithdrawals[msg.sender][_index];
        require(scheduledTx.active, "No active scheduled withdrawal");
        
        // Refund the amount back to the user's balance
        accounts[msg.sender].balance += scheduledTx.amount;
        scheduledTx.active = false;

        emit ScheduledWithdrawCancelled(msg.sender, scheduledTx.amount, _index);
    }

    // Execute scheduled withdrawal with reentrancy protection
    function executeScheduledWithdraw(uint256 _index) external 
    {
        require(_index < scheduledWithdrawals[msg.sender].length, "Invalid withdrawal index");
        ScheduledWithdraw storage scheduledTx = scheduledWithdrawals[msg.sender][_index];
        require(scheduledTx.active, "No active scheduled withdrawal");
        require(block.timestamp >= scheduledTx.unlockTime, "Unlock time has not been reached");

        // Mark the scheduled withdrawal as inactive
        scheduledTx.active = false;

        // Transfer the funds (no need to deduct the balance again)
        payable(scheduledTx.recipient).transfer(scheduledTx.amount);

        emit ScheduledWithdrawExecuted(msg.sender, scheduledTx.amount, _index);
    }

    // Function to list all scheduled withdrawals for the caller
    function listScheduledWithdrawals(address _account) external view returns (ScheduledWithdraw[] memory) {
        return scheduledWithdrawals[_account];
    }

    // Add a child account under a parent
    function addChildAccount(address _child) external {
        require(accounts[_child].parent == address(0), "Child account already exists");
        require(_child != msg.sender, "Parent cannot add themselves as a child");

        accounts[_child] = Account({
            balance: 0,
            startTime: block.timestamp, 
            contractEndTime: block.timestamp + 18 * 365 days, // need to change to follow yunshen code
            parent: msg.sender,
            isChild: true
        });

        emit ChildAccountAdded(msg.sender, _child);
    }

    function listWithdrawals(address _account) external view returns (Withdrawal[] memory) {
        return withdrawalHistory[_account];
    }

    // Schedule withdrawal for a child (only the parent can do this)
    function addScheduleWithdrawForChild(address _child, uint256 _amountWithdraw, uint256 _unlockTime) 
        external 
        onlyParent(_child)
        sufficientBalance(_child, _amountWithdraw)
    {
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");

        // Deduct the amount from the child's balance at the time of scheduling
        accounts[_child].balance -= _amountWithdraw;

        scheduledWithdrawals[_child].push(ScheduledWithdraw({
            recipient: _child,
            amount: _amountWithdraw,
            unlockTime: _unlockTime,
            active: true
        }));

        emit ScheduledWithdrawCreated(_child, _amountWithdraw, _unlockTime);
    }
}
