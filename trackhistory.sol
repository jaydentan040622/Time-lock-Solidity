// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransactionTracker {
    // Mapping to store the balance of each address
    mapping(address => uint256) public balances;

    // Nested mapping to track transaction amounts between users
    mapping(address => mapping(address => uint256)) public transactionsBetweenUsers;

    // Event to log deposits
    event Deposit(address indexed sender, address indexed receiver, uint256 amount);

    // Event to log withdrawals
    event Withdrawal(address indexed user, uint256 amount);

    // Function to deposit Ether and record the transaction between two addresses
    function deposit(address _receiver) public payable {
        require(msg.value > 0, "Must send some Ether");

        // Update the balance of the sender
        balances[msg.sender] += msg.value;

        // Track the transaction between the sender and the receiver
        transactionsBetweenUsers[msg.sender][_receiver] += msg.value;

        // Emit a deposit event
        emit Deposit(msg.sender, _receiver, msg.value);
    }

    // Function to get the total amount transacted between two addresses
    function getTotalTransactionAmount(address _sender, address _receiver) public view returns (uint256) {
        return transactionsBetweenUsers[_sender][_receiver];
    }

    // Improved withdraw function
    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= balances[msg.sender], "Insufficient balance");

        // Update balance before transfer to prevent reentrancy attacks
        balances[msg.sender] -= amount;

        // Transfer the Ether to the sender
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        // Emit a withdrawal event
        emit Withdrawal(msg.sender, amount);
    }

    // New function to get contract balance
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
