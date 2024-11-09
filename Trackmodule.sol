// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Transaction {
    struct Account {
        uint256 balance;
    }

    struct TransferRecord {
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }

    struct ScheduledTransfer {
        address receiver;
        uint256 amount;
        uint256 unlockTime;
        bool active;
    }

    mapping(address => Account) public accounts;
    mapping(address => TransferRecord[]) public transferHistory;
    mapping(address => ScheduledTransfer[]) public scheduledTransfers;

    modifier sufficientBalance(address _account, uint256 _amount) {
        require(accounts[_account].balance >= _amount, "Insufficient balance");
        _;
    }

    event FundsAdded(address indexed account, uint256 amount);
    event TransferExecuted(address indexed sender, address indexed receiver, uint256 amount);
    event ScheduledTransferCreated(address indexed sender, address indexed receiver, uint256 amount, uint256 unlockTime);
    event ScheduledTransferCancelled(address indexed sender, uint256 amount, uint256 index);
    event ScheduledTransferExecuted(address indexed sender, address indexed receiver, uint256 amount, uint256 index);
    event LogError(string reason);

    function addFunds(uint256 _amount) external payable {
        require(msg.value == _amount, "Sent Ether does not match the specified amount");
        accounts[msg.sender].balance += _amount;
        emit FundsAdded(msg.sender, _amount);
    }

    function checkBalance(address _account) external view returns (uint256) {
        return accounts[_account].balance;
    }

    function instantTransfer(address _to, uint256 _amount) external sufficientBalance(msg.sender, _amount) {
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

    // Schedule a transfer
function addScheduledTransfer(address _to, uint256 _amount, uint256 _timePeriod)
    external
    sufficientBalance(msg.sender, _amount)
{
    require(_to != address(0), "Invalid receiver address");
    require(_to != msg.sender, "Cannot transfer to yourself");
    require(_timePeriod > 0, "Time period must be greater than zero");
    require(_amount > 0, "Amount must be greater than zero");

    uint256 unlockTime = block.timestamp + _timePeriod;

    // Effects
    accounts[msg.sender].balance -= _amount;

    scheduledTransfers[msg.sender].push(ScheduledTransfer({
        receiver: _to,
        amount: _amount,
        unlockTime: unlockTime,
        active: true
    }));

    // Events
    emit ScheduledTransferCreated(msg.sender, _to, _amount, unlockTime);
}


function cancelScheduledTransfer(uint256 _index) external {
    require(_index < scheduledTransfers[msg.sender].length, "Invalid transfer index");
    ScheduledTransfer storage scheduledTx = scheduledTransfers[msg.sender][_index];
    require(scheduledTx.active, "No active scheduled transfer");
    require(block.timestamp < scheduledTx.unlockTime, "Transfer unlock time has passed");

    uint256 refundAmount = scheduledTx.amount;

    // Effects
    scheduledTx.active = false;
    // Remove this line: scheduledTx.amount = 0;  // Reset the amount to avoid reentrancy issues

    // Interactions
    accounts[msg.sender].balance += refundAmount;

    emit ScheduledTransferCancelled(msg.sender, refundAmount, _index);
}



// Execute a scheduled transfer
function executeScheduledTransfer(address _sender, uint256 _index) external {
    require(_index < scheduledTransfers[_sender].length, "Invalid transfer index");
    ScheduledTransfer storage scheduledTx = scheduledTransfers[_sender][_index];
    
    require(scheduledTx.active, "No active scheduled transfer");
    require(block.timestamp >= scheduledTx.unlockTime, "Unlock time has not been reached");
    require(msg.sender == _sender || msg.sender == scheduledTx.receiver, "Only sender or receiver can execute");

    uint256 transferAmount = scheduledTx.amount;
    address receiver = scheduledTx.receiver;

    // Effects
    scheduledTx.active = false;
    accounts[receiver].balance += transferAmount;

    // Record the transfer
    transferHistory[_sender].push(TransferRecord({
        sender: _sender,
        receiver: receiver,
        amount: transferAmount,
        timestamp: block.timestamp
    }));

    emit ScheduledTransferExecuted(_sender, receiver, transferAmount, _index);
    emit TransferExecuted(_sender, receiver, transferAmount);
}

function listScheduledTransfers(address _account) external view returns (ScheduledTransfer[] memory) {
    require(_account != address(0), "Invalid account address");
    ScheduledTransfer[] memory transfers = scheduledTransfers[_account];
    require(transfers.length > 0, "No scheduled transfers found for this account");
    return transfers;
}
}