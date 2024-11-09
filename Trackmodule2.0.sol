// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Transaction {
    struct Account { uint256 balance; }
    struct Transfer { address sender; address receiver; uint256 amount; uint256 timestamp; }
    struct ScheduledTransfer { address receiver; uint256 amount; uint256 unlockTime; bool active; }

    mapping(address => Account) public accounts;
    mapping(address => Transfer[]) public transferHistory;
    mapping(address => ScheduledTransfer[]) public scheduledTransfers;

    event TransferExecuted(address indexed sender, address indexed receiver, uint256 amount);
    event ScheduledTransferCreated(address indexed sender, address indexed receiver, uint256 amount, uint256 unlockTime);
    event ScheduledTransferCancelled(address indexed sender, uint256 amount, uint256 index);
    event ScheduledTransferExecuted(address indexed sender, address indexed receiver, uint256 amount, uint256 index);

    function addFunds() external payable{
        accounts[msg.sender].balance += msg.value;
    }

    function checkBalance(address _account) external view returns (uint256) {
        return accounts[_account].balance;
    }

    function instantTransfer(address _to, uint256 _amount) external{
        require(accounts[msg.sender].balance >= _amount, "Insufficient balance");
        require(_to != address(0) && _to != msg.sender, "Invalid receiver");

        accounts[msg.sender].balance -= _amount;
        accounts[_to].balance += _amount;

        Transfer memory newRecord = Transfer(msg.sender, _to, _amount, block.timestamp);
        transferHistory[msg.sender].push(newRecord);
        transferHistory[_to].push(newRecord);

        emit TransferExecuted(msg.sender, _to, _amount);
    }

    function scheduleAutoExecution(address _to, uint256 _amount, uint256 _unlockTime) external {
        require(accounts[msg.sender].balance >= _amount, "Insufficient balance");
        require(_to != address(0) && _to != msg.sender, "Invalid receiver");
        require(_amount > 0 && _unlockTime > block.timestamp, "Invalid amount or time");

        accounts[msg.sender].balance -= _amount;
        scheduledTransfers[msg.sender].push(ScheduledTransfer(_to, _amount, _unlockTime, true));

        emit ScheduledTransferCreated(msg.sender, _to, _amount, _unlockTime);
    }

    function executeAutoScheduledTransfers() external {
        ScheduledTransfer[] storage transfers = scheduledTransfers[msg.sender];
        for (uint256 i = 0; i < transfers.length; i++) {
            ScheduledTransfer storage transfer = transfers[i];
            if (transfer.active && block.timestamp >= transfer.unlockTime) {
                transfer.active = false;
                accounts[transfer.receiver].balance += transfer.amount;

                Transfer memory newRecord = Transfer(msg.sender, transfer.receiver, transfer.amount, block.timestamp);
                transferHistory[msg.sender].push(newRecord);
                transferHistory[transfer.receiver].push(newRecord);

                emit ScheduledTransferExecuted(msg.sender, transfer.receiver, transfer.amount, i);
                emit TransferExecuted(msg.sender, transfer.receiver, transfer.amount);
            }
        }
    }

    function cancelScheduledTransfer(uint256 _index) external {
        ScheduledTransfer storage transfer = scheduledTransfers[msg.sender][_index];
        require(transfer.active && transfer.unlockTime > block.timestamp, "Invalid transfer");

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
        ScheduledTransfer[] storage transfers = scheduledTransfers[msg.sender];
        uint256 len = transfers.length;
        receivers = new address[](len);
        amounts = new uint256[](len);
        unlockTimes = new uint256[](len);
        activeStatuses = new bool[](len);

        for (uint256 i = 0; i < len; i++) {
            ScheduledTransfer storage transfer = transfers[i];
            receivers[i] = transfer.receiver;
            amounts[i] = transfer.amount;
            unlockTimes[i] = transfer.unlockTime;
            activeStatuses[i] = transfer.active;
        }
    }

    function getTransferHistory(address _user1, address _user2) external view returns (Transfer[] memory) {
        require(_user1 != address(0) && _user2 != address(0) && _user1 != _user2, "Invalid addresses");

        Transfer[] storage history = transferHistory[_user1];
        uint256 count = 0;
        for (uint256 i = 0; i < history.length; i++) {
            if (history[i].sender == _user2 || history[i].receiver == _user2) {
                count++;
            }
        }

        Transfer[] memory result = new Transfer[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < history.length; i++) {
            if (history[i].sender == _user2 || history[i].receiver == _user2) {
                result[index] = history[i];
                index++;
            }
        }

        return result;
    }

    function getAllTransferHistory(address _user) external view returns (Transfer[] memory) {
        return transferHistory[_user];
    }

    function getTransferDetails(address _user, uint256 _index) external view returns (address sender, address receiver, uint256 amount, uint256 timestamp) {
        require(_index < transferHistory[_user].length, "Invalid index or no transfer history");
        Transfer storage record = transferHistory[_user][_index];
        return (record.sender, record.receiver, record.amount, record.timestamp);
    }

    function getTotalTransactionAmount(address _sender, address _receiver) external view returns (uint256) {
        uint256 totalAmount = 0;
        Transfer[] storage history = transferHistory[_sender];
        for (uint256 i = 0; i < history.length; i++) {
            if (history[i].receiver == _receiver) {
                totalAmount += history[i].amount;
            }
        }
        return totalAmount;
    }
}

