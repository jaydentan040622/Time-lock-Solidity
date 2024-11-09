@ -0,0 +1,384 @@
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
        address sender;
        address receiver;
        uint256 amount;
        uint256 unlockTime;
        bool active;
    }

    mapping(address => Account) public accounts;
    mapping(address => TransferRecord[]) public transferHistory;
    mapping(address => ScheduledTransfer[]) public scheduledTransfers;

    address public owner;
    bool public paused;

    modifier sufficientBalance(address _account, uint256 _amount) {
        require(accounts[_account].balance >= _amount, "Insufficient balance");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    event FundsAdded(address indexed account, uint256 amount);
    event TransferExecuted(address indexed sender, address indexed receiver, uint256 amount);
    event ScheduledTransferCreated(address indexed sender, address indexed receiver, uint256 amount, uint256 unlockTime);
    event ScheduledTransferCancelled(address indexed sender, uint256 amount, uint256 index);
    event ScheduledTransferExecuted(address indexed sender, address indexed receiver, uint256 amount, uint256 index);
    event Paused();
    event Unpaused();
    // event FeeCollected(address indexed from, uint256 amount);

        constructor() {
        owner = msg.sender;
        paused = false;
    }

    function addFunds(uint256 _amount) external payable whenNotPaused{
        require(msg.value == _amount, "Sent Ether does not match the specified amount");
        accounts[msg.sender].balance += _amount;
        emit FundsAdded(msg.sender, _amount);
    }

    function checkBalance(address _account) external view returns (uint256) {
        return accounts[_account].balance;
    }

    function instantTransfer(address _to, uint256 _amount) external whenNotPaused sufficientBalance(msg.sender, _amount) {
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

// function addScheduledTransfer(address _to, uint256 _amount, uint256 _timePeriod) external sufficientBalance(msg.sender, _amount) {
//     require(_to != address(0), "Invalid receiver address");
//     require(_to != msg.sender, "Cannot schedule transfer to yourself");
//     require(_amount > 0, "Amount must be greater than 0");
    

    
//     uint256 unlockTime = block.timestamp + _timePeriod;

//     // Deduct the amount from the sender's balance immediately
//     accounts[msg.sender].balance -= _amount;

//     scheduledTransfers[msg.sender].push(ScheduledTransfer({
//         sender: msg.sender,
//         receiver: _to,
//         amount: _amount,
//         unlockTime: unlockTime,
//         active: true
//     }));

//     emit ScheduledTransferCreated(msg.sender, _to, _amount, unlockTime);
// }

// function executeScheduledTransfer(uint256 _index) external {
//     // Check if the sender has a scheduled transfer at the specified index
//     require(_index < scheduledTransfers[msg.sender].length, "Invalid transfer index");
    
//     ScheduledTransfer storage scheduledTx = scheduledTransfers[msg.sender][_index];

//     // Ensure the scheduled transfer is active and the unlock time has been reached
//     require(scheduledTx.active, "No active scheduled transfer");
//     require(block.timestamp >= scheduledTx.unlockTime, "Unlock time has not been reached");

//     // Transfer amount and receiver address
//     uint256 transferAmount = scheduledTx.amount;
//     address receiver = scheduledTx.receiver;

//     // Effects: Mark the transfer as inactive and update receiver's balance
//     scheduledTx.active = false;
//     accounts[receiver].balance += transferAmount; // Add to receiver

//     // Record the transfer in history
//     transferHistory[msg.sender].push(TransferRecord({
//         sender: msg.sender,
//         receiver: receiver,
//         amount: transferAmount,
//         timestamp: block.timestamp
//     }));
    
//     // Emit events for the executed transfer
//     emit ScheduledTransferExecuted(msg.sender, receiver, transferAmount, _index);
//     emit TransferExecuted(msg.sender, receiver, transferAmount);
// }

// function cancelScheduledTransfer(uint256 _index) external {
//     require(_index < scheduledTransfers[msg.sender].length, "Invalid transfer index");
//     ScheduledTransfer storage transfer = scheduledTransfers[msg.sender][_index];
    
//     require(transfer.active, "Transfer is not active");
//     require(block.timestamp < transfer.unlockTime, "Transfer is already unlocked");

//     transfer.active = false;
    
//     // Refund the amount to the sender's balance
//     accounts[msg.sender].balance += transfer.amount;

//     emit ScheduledTransferCancelled(msg.sender, transfer.amount, _index);
// }

//     function getTransferHistory(address _user1, address _user2) external view returns (TransferRecord[] memory) {
//         require(_user1 != address(0) && _user2 != address(0), "Invalid addresses");
//         require(_user1 != _user2, "Addresses must be different");

//         uint256 count = 0;
//         for (uint256 i = 0; i < transferHistory[_user1].length; i++) {
//             if (transferHistory[_user1][i].sender == _user2 || transferHistory[_user1][i].receiver == _user2) {
//                 count++;
//             }
//         }

//         TransferRecord[] memory result = new TransferRecord[](count);
//         uint256 index = 0;
//         for (uint256 i = 0; i < transferHistory[_user1].length; i++) {
//             if (transferHistory[_user1][i].sender == _user2 || transferHistory[_user1][i].receiver == _user2) {
//                 result[index] = transferHistory[_user1][i];
//                 index++;
//             }
//         }


//         return result;
//     }


//     //list the scheduled transfers
// function getScheduledTransfers(address _user) external view returns (ScheduledTransfer[] memory, uint256[] memory, uint256[] memory) {
//     // Count active scheduled transfers
//     uint256 activeCount = 0;
//     for (uint256 i = 0; i < scheduledTransfers[_user].length; i++) {
//         if (scheduledTransfers[_user][i].active) {
//             activeCount++;
//         }
//     }

//     // Create arrays to store active transfers, remaining times, and indices
//     ScheduledTransfer[] memory activeTransfers = new ScheduledTransfer[](activeCount);
//     uint256[] memory remainingTimes = new uint256[](activeCount);
//     uint256[] memory indices = new uint256[](activeCount);
    
//     // Fill the arrays with active transfers, calculate remaining times, and store indices
//     uint256 index = 0;
//     for (uint256 i = 0; i < scheduledTransfers[_user].length; i++) {
//         if (scheduledTransfers[_user][i].active) {
//             activeTransfers[index] = scheduledTransfers[_user][i];
//             if (block.timestamp < scheduledTransfers[_user][i].unlockTime) {
//                 remainingTimes[index] = scheduledTransfers[_user][i].unlockTime - block.timestamp;
//             } else {
//                 remainingTimes[index] = 0;
//             }
//             indices[index] = i;
//             index++;
//         }
//     }
//     return (activeTransfers, remainingTimes, indices);
// }

// //list scheduled transfers that are pending
// function getPendingScheduledTransfers(address _user) external view returns (ScheduledTransfer[] memory, uint256[] memory) {
//     // Count pending scheduled transfers
//     uint256 pendingCount = 0;
//     for (uint256 i = 0; i < scheduledTransfers[_user].length; i++) {
//         if (scheduledTransfers[_user][i].active && block.timestamp < scheduledTransfers[_user][i].unlockTime) {
//             pendingCount++;
//         }
//     }

//     // Create arrays to store pending transfers and remaining times
//     ScheduledTransfer[] memory pendingTransfers = new ScheduledTransfer[](pendingCount);
//     uint256[] memory remainingTimes = new uint256[](pendingCount);
    
//     // Fill the arrays with pending transfers and calculate remaining times
//     uint256 index = 0;
//     for (uint256 i = 0; i < scheduledTransfers[_user].length; i++) {
//         if (scheduledTransfers[_user][i].active && block.timestamp < scheduledTransfers[_user][i].unlockTime) {
//             pendingTransfers[index] = scheduledTransfers[_user][i];
//             remainingTimes[index] = scheduledTransfers[_user][i].unlockTime - block.timestamp;
//             index++;
//         }
//     }
//     return (pendingTransfers, remainingTimes);
// }


function scheduleAutoExecution(address _to, uint256 _amount, uint256 _unlockTime) external sufficientBalance(msg.sender, _amount) {
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

        function pause() external onlyOwner {
        paused = true;
        emit Paused();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused();
    }
}
