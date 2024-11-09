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

    struct TransferRecord {
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }

    struct ScheduledTransfer {
        address sender;
        address receiver;
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
    mapping(address => TransferRecord[]) public transferHistory;
    mapping(address => ScheduledTransfer[]) public scheduledTransfers;
    mapping(address => Withdrawal[]) public withdrawalHistory;
    // Events
    event FundsAdded(address indexed account, uint256 amount);
    event WithdrawalMade(address indexed account, uint256 amount);
    event ScheduledWithdrawCreated(address indexed account, uint256 amount, uint256 unlockTime);
    event ScheduledWithdrawCancelled(address indexed account, uint256 amount, uint256 index);
    event ScheduledWithdrawExecuted(address indexed account, uint256 amount, uint256 index);
    event ChildAccountAdded(address indexed parent, address child);

    //hasnhen
    event TransferExecuted(address indexed sender, address indexed receiver, uint256 amount);
    event ScheduledTransferCreated(address indexed sender, address indexed receiver, uint256 amount, uint256 unlockTime);
    event ScheduledTransferCancelled(address indexed sender, uint256 amount, uint256 index);
    event ScheduledTransferExecuted(address indexed sender, address indexed receiver, uint256 amount, uint256 index);
    event Paused();
    event Unpaused();

    address public owner;
    bool public paused;

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

    function listWithdrawals(address _account) external view returns (Withdrawal[] memory) {
        return withdrawalHistory[_account];
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

    //hanshen
    function instantTransfer(address _to, uint256 _amount) external sufficientBalance(msg.sender, _amount) onlyAdult(msg.sender){
        require(_to != address(0), "Invalid receiver address");
        require(_to != msg.sender, "Cannot transfer to yourself");

        accounts[msg.sender].balance -= _amount;
        accounts[_to].balance += _amount;

        TransferRecord memory newRecord = TransferRecord({
            sender: msg.sender,
            receiver: _to,
            amount: _amount,
            timestamp: block.timestamp
        });
        
        transferHistory[msg.sender].push(newRecord);
        transferHistory[_to].push(newRecord);

        emit TransferExecuted(msg.sender, _to, _amount);
    }

    function scheduleAutoExecution(address _to, uint256 _amount, uint256 _unlockTime) external sufficientBalance(msg.sender, _amount) onlyAdult(msg.sender){
        require(_to != address(0), "Invalid receiver address");
        require(_to != msg.sender, "Cannot schedule transfer to yourself");
        require(_amount > 0, "Amount must be greater than 0");
        require(_unlockTime > block.timestamp, "Unlock time must be in the future");

        // Deduct the amount from the sender's balance immediately
        accounts[msg.sender].balance -= _amount;

        scheduledTransfers[msg.sender].push(ScheduledTransfer({
            sender: msg.sender,
            receiver: _to,
            amount: _amount,
            unlockTime: _unlockTime,
            active: true
        }));

        emit ScheduledTransferCreated(msg.sender, _to, _amount, _unlockTime);
    }

    function executeAutoScheduledTransfers() external {
        uint256 transferCount = scheduledTransfers[msg.sender].length;
        for (uint256 i = 0; i < transferCount; i++) {
            ScheduledTransfer storage transfer = scheduledTransfers[msg.sender][i];
            if (transfer.active && block.timestamp >= transfer.unlockTime) {
                transfer.active = false;
                accounts[transfer.receiver].balance += transfer.amount;

                transferHistory[transfer.sender].push(TransferRecord({
                    sender: transfer.sender,
                    receiver: transfer.receiver,
                    amount: transfer.amount,
                    timestamp: block.timestamp
                }));
                transferHistory[transfer.receiver].push(TransferRecord({
                    sender: transfer.sender,
                    receiver: transfer.receiver,
                    amount: transfer.amount,
                    timestamp: block.timestamp
                }));

                emit ScheduledTransferExecuted(transfer.sender, transfer.receiver, transfer.amount, i);
                emit TransferExecuted(transfer.sender, transfer.receiver, transfer.amount);
            }
        }
    }

    function cancelScheduledTransfer(uint256 _index) external {
        require(_index < scheduledTransfers[msg.sender].length, "Invalid transfer index");
        ScheduledTransfer storage transfer = scheduledTransfers[msg.sender][_index];
        require(transfer.active, "Transfer is not active");
        require(transfer.unlockTime > block.timestamp, "Transfer is already due");

        transfer.active = false;
        accounts[msg.sender].balance += transfer.amount;

        emit ScheduledTransferCancelled(msg.sender, transfer.amount, _index);
    }

    function getAllScheduledTransfers() external view returns (
        address[] memory receivers,
        uint256[] memory amounts,
        uint256[] memory unlockTimes,
        bool[] memory activeStatuses
    ) {
        uint256 transferCount = scheduledTransfers[msg.sender].length;

        // Initialize arrays to store scheduled transfer details
        receivers = new address[](transferCount);
        amounts = new uint256[](transferCount);
        unlockTimes = new uint256[](transferCount);
        activeStatuses = new bool[](transferCount);

        // Loop through the caller's scheduled transfers and store the details
        for (uint256 i = 0; i < transferCount; i++) {
            ScheduledTransfer storage transfer = scheduledTransfers[msg.sender][i];
            receivers[i] = transfer.receiver;
            amounts[i] = transfer.amount;
            unlockTimes[i] = transfer.unlockTime;
            activeStatuses[i] = transfer.active;
        }
        
        return (receivers, amounts, unlockTimes, activeStatuses);
    }


    function getTransferHistory(address _user1, address _user2) external view returns (TransferRecord[] memory) {
        require(_user1 != address(0) && _user2 != address(0), "Invalid addresses");
        require(_user1 != _user2, "Addresses must be different");

        uint256 count = 0;
        for (uint256 i = 0; i < transferHistory[_user1].length; i++) {
            if (transferHistory[_user1][i].sender == _user2 || transferHistory[_user1][i].receiver == _user2) {
                count++;
            }
        }

        TransferRecord[] memory result = new TransferRecord[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < transferHistory[_user1].length; i++) {
            if (transferHistory[_user1][i].sender == _user2 || transferHistory[_user1][i].receiver == _user2) {
                result[index] = transferHistory[_user1][i];
                index++;
            }
        }

        return result;
    }

    function getAllTransferHistory(address _user) external view returns (TransferRecord[] memory) {
        return transferHistory[_user];
    }

    function getTransferDetails(address _user, uint256 _index) external view returns (address sender, address receiver, uint256 amount, uint256 timestamp) {
        require(_index < transferHistory[_user].length, "Invalid index or no transfer history");
        TransferRecord storage record = transferHistory[_user][_index];
        return (record.sender, record.receiver, record.amount, record.timestamp);
    }

    function getTotalTransactionAmount(address _sender, address _receiver) external view returns (uint256) {
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < transferHistory[_sender].length; i++) {
            if (transferHistory[_sender][i].receiver == _receiver) {
                totalAmount += transferHistory[_sender][i].amount;
            }
        }
        return totalAmount;
    }

    enum AccountType { PARENT, CHILD }
    enum AccountStatus { ACTIVE, ARCHIVED }

    struct User {
        address account;
        string name;
        string email;
        uint age;
        AccountType accountType;
        address parent; // Address of the parent account (for child accounts)
        AccountStatus status; // Status of the account (active or archived)
        uint archiveTimestamp;
    }
    uint constant ARCHIVE_PERIOD = 365 days;
    mapping(address => User) public users;
    mapping(address => address[]) public children; // Mapping from parent to child accounts
    event ProfileModified(address indexed user, string name, string email, uint age, uint timestamp);
    event AccountArchived(address indexed user, uint timestamp);
    event AccountReactivated(address indexed user, uint timestamp);
    event UserRegistered(address indexed user, string name, string email, uint age, uint timestamp);
    event UserLoggedIn(address indexed user, uint timestamp); // Added event for login
        modifier accountDoesNotExist(address _account) {
        require(users[_account].account == address(0), "Account already exists. Please use another address.");
        _;
    }

    modifier validParent(address _parent) {
        if (_parent != address(0)) {
            require(users[_parent].account != address(0), "Parent account does not exist.");
        }
        _;
    }

    modifier validateAge(uint _age, address _parent) {
        require(
            (_parent == address(0) && _age >= 18) || (_parent != address(0) && _age < 18),
            _parent == address(0) ? "Age must be 18 or older to register as a parent." : "Age must be below 18 to register as a child."
        );
        _;
    }

    modifier ageRestriction(address _user, uint _age) {
        require(users[_user].account != address(0), "Account does not exist.");
        if (users[_user].accountType == AccountType.CHILD) {
            require(_age < 18, "Child's age cannot be 18 or older.");
        } else if (users[_user].accountType == AccountType.PARENT) {
            require(_age >= 18, "Parent's age cannot be below 18.");
        }
        _;
    }
    
    modifier accountActive(address _account) {
        require(users[_account].status == AccountStatus.ACTIVE, "Account is archived.");
        _;
    }
    function register(string memory _name, string memory _email, uint _age, address _parent, AccountType _accountType) public 
        accountDoesNotExist(msg.sender)
        validParent(_parent)
        validateAge(_age, _parent)
{
    require(
        (_accountType == AccountType.PARENT && _parent == address(0)) || (_accountType == AccountType.CHILD && _parent != address(0)),
        "Parent address must be provided for children, and no parent for parent accounts."
    );
    
    users[msg.sender] = User(msg.sender, _name, _email, _age, _accountType, _parent, AccountStatus.ACTIVE, 0);

    if (_parent != address(0)) {
        children[_parent].push(msg.sender);
    }

    emit UserRegistered(msg.sender, _name, _email, _age, block.timestamp);
}


    function getProfile() public view returns (User memory) {
        return users[msg.sender];
    }

    function getParent(address _child) public view returns (User memory) {
        address parentAddress = users[_child].parent;
        return users[parentAddress];
    }

    function getChildren(address _parent) public view returns (address[] memory) {
        return children[_parent];
    }

    function modifyProfile(string memory _name, string memory _email, uint _age) public ageRestriction(msg.sender, _age) {
        if (users[msg.sender].accountType == AccountType.CHILD) {
            require(modificationAccessGranted[msg.sender], "Modification access has not been granted by the parent.");
            if (_age >= 18) {
                upgradeToParent(msg.sender);
            }
        }

        users[msg.sender].name = _name;
        users[msg.sender].email = _email;
        users[msg.sender].age = _age;
        emit ProfileModified(msg.sender, _name, _email, _age, block.timestamp);
    }
    

     function login(address _account) public  returns (bool) {
    bool loggedIn = users[_account].account != address(0);
        
            emit UserLoggedIn(_account, block.timestamp); // Emit event on login
        
        return loggedIn;
}
    function deleteAccount() public {
        require(users[msg.sender].account != address(0), "Account does not exist");

        address parent = users[msg.sender].parent;
        if (parent != address(0)) {
            address[] storage parentChildren = children[parent];
            for (uint i = 0; i < parentChildren.length; i++) {
                if (parentChildren[i] == msg.sender) {
                    parentChildren[i] = parentChildren[parentChildren.length - 1];
                    parentChildren.pop();
                    break;
                }
            }
        }
        
        delete users[msg.sender];
    }
    function migrateAccount(address _newAddress) public {
    // Ensure the old account exists and the new address does not have an account

    require(users[_newAddress].account == address(0), "New address already has an account");

    // Copy the user data from old address (msg.sender) to new address (_newAddress)
    User memory user = users[msg.sender];
    users[_newAddress] = users[msg.sender];
    users[_newAddress].account = _newAddress;

    // Handle migration for parent accounts with child accounts
    if (user.accountType == AccountType.PARENT) {
        // Copy the child accounts to the new address
        address[] memory childAccounts = children[msg.sender];
        delete children[msg.sender]; // Remove the children from the old address
        children[_newAddress] = childAccounts;

        // Update the parent address in each child account to the new address
        for (uint i = 0; i < childAccounts.length; i++) {
            users[childAccounts[i]].parent = _newAddress;
        }
    }

    // Archive the old account
    users[msg.sender].status = AccountStatus.ARCHIVED;
    users[msg.sender].archiveTimestamp = block.timestamp;
    emit AccountArchived(msg.sender, block.timestamp);
}
    function archiveAccount() public accountActive(msg.sender) {
        users[msg.sender].status = AccountStatus.ARCHIVED;
        users[msg.sender].archiveTimestamp = block.timestamp;
         emit AccountArchived(msg.sender, block.timestamp);
    }

    function reactivateAccount() public {
        require(users[msg.sender].status == AccountStatus.ARCHIVED, "Account is not archived.");
        require(block.timestamp <= users[msg.sender].archiveTimestamp + ARCHIVE_PERIOD, "Cannot reactivate. Account has been permanently deleted.");

        users[msg.sender].status = AccountStatus.ACTIVE;
        users[msg.sender].archiveTimestamp = 0;
         emit AccountReactivated(msg.sender, block.timestamp);
    }

    function checkArchiveStatus() public {
        if (users[msg.sender].status == AccountStatus.ARCHIVED && block.timestamp > users[msg.sender].archiveTimestamp + ARCHIVE_PERIOD) {
            delete users[msg.sender];
        }   
    }
    function getUserStatus(address _user) public view returns (string memory) {
        if (users[_user].status == AccountStatus.ARCHIVED) {
            return "ARCHIVED";
        } else {
            return "ACTIVE";
        }
    }
    function getArchiveTimestamp(address _account) public view returns (uint) {
    return users[_account].archiveTimestamp;
}
    function getTimeUntilDeletion(address _user) public view returns (uint256) {
        if (users[_user].status == AccountStatus.ARCHIVED) {
            uint256 timeUntilDeletion = (users[_user].archiveTimestamp + 365 days) - block.timestamp;
            return timeUntilDeletion > 0 ? timeUntilDeletion : 0;
        } else {
            return 0;
        }
    }
    // Add a new mapping to store modification access for children
mapping(address => bool) public modificationAccessGranted;

// Event to notify when access is granted
event ModificationAccessGranted(address indexed parent, address indexed child, uint timestamp);

// Event to notify when access is revoked
event ModificationAccessRevoked(address indexed parent, address indexed child, uint timestamp);

// Function for parent to grant profile modification access to a child
function grantModificationAccess(address _child) public {
    require(users[msg.sender].accountType == AccountType.PARENT, "Only parents can grant modification access");
    require(users[_child].parent == msg.sender, "The child does not belong to this parent");

    // Grant modification access
    modificationAccessGranted[_child] = true;

    emit ModificationAccessGranted(msg.sender, _child, block.timestamp);
}

// Function to revoke modification access for a child
function revokeModificationAccess(address _child) public {
    require(users[msg.sender].accountType == AccountType.PARENT, "Only parents can revoke modification access");
    require(users[_child].parent == msg.sender, "The child does not belong to this parent");

    // Revoke modification access
    modificationAccessGranted[_child] = false;

    emit ModificationAccessRevoked(msg.sender, _child, block.timestamp);
}
function upgradeToParent(address _child) internal {
        require(users[_child].accountType == AccountType.CHILD, "Account is not a child account");
       

        users[_child].accountType = AccountType.PARENT; // Change account type to parent

        // Remove the child account from the parent's children array
        address parent = users[_child].parent;
        if (parent != address(0)) {
            address[] storage parentChildren = children[parent];
            for (uint i = 0; i < parentChildren.length; i++) {
                if (parentChildren[i] == _child) {
                    parentChildren[i] = parentChildren[parentChildren.length - 1];
                    parentChildren.pop();
                    break;
                }
            }
        }

        // Clear the parent reference, as the user is now a parent
        users[_child].parent = address(0);
    }
    uint256 public constant SECONDS_IN_A_YEAR = 365 * 24 * 60 * 60;
// Function to copy User details into Account
    function copyUserToAccount(address userAddress) public {
        // Fetch the user data from the mapping
        User memory user = users[userAddress];

        // Initialize a new Account object
        Account storage account = accounts[userAddress];

        // Convert age to startTime
        uint256 currentTime = block.timestamp;
        uint256 ageInSeconds = user.age * SECONDS_IN_A_YEAR;
        account.startTime = currentTime - ageInSeconds;

        // Set the isChild flag based on the accountType (1 for child, 0 for parent)
        account.isChild = (user.accountType == AccountType.CHILD);

        // Set parent if the user is a child
        if (account.isChild) {
            account.parent = user.parent;
        }


    }

    //Utility
    function addInterestBalance(address account,uint256 addAmount) public {
        accounts[account].balance += addAmount;
    }

    function deductInterestBalance(address account,uint256 deductAmount) public {
        accounts[account].balance -= deductAmount;
        payable(account).transfer(deductAmount);

    }



}
