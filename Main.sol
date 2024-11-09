// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./hjhsyscombine.sol"; // Import the DepositAndWithdraw contract
import "./Interest.sol"; // Import the InterestModule

contract Main {
    DepositAndWithdraw public combine; // Instance of the DepositAndWithdraw contract
    InterestModule public interestModule; // Instance of InterestModule

    constructor(address _combineAddress, address payable _interestModuleAddress) payable{
        combine = DepositAndWithdraw(_combineAddress); // Initialize the DepositAndWithdraw contract
        interestModule = InterestModule(_interestModuleAddress); // Initialize the InterestModule
    }

    // Function to deposit Ether
    function deposit() public payable {
        combine.addFunds(msg.value); // Call the deposit function in the DepositAndWithdraw contract
        interestModule.deposit(msg.value,msg.sender);//Testing
    }

    //Interest Module ----Start
    function interestCalculator(uint256 amount, uint256 startEpoch, uint256 endEpoch) public view returns (uint256 ,uint256 ,uint256) {
        return interestModule.interestCalculator(amount,startEpoch,endEpoch);
    }

    function withdrawInterest() public  {
        //if withdraw success, send ether to user wallet
        if(interestModule.withdrawInterest(msg.sender)){
            payable(msg.sender).transfer(interestModule.calculateInterest(msg.sender));
        }  
    }

    function addInterest() public  {
        interestModule.addInterest(msg.sender);
    }

    function getUserAddInterestHistory() public view returns (InterestModule.InterestHistory[] memory) {
        return interestModule.getAddInterestHistory(msg.sender);
    }

    function getWithdrawalHistory() public view returns (InterestModule.InterestHistory[] memory) {
        return interestModule.getWithdrawalHistory(msg.sender);
    }

    function getDistributionHistory() public view returns (InterestModule.InterestHistory[] memory) {
        return interestModule.getDistributionHistory(msg.sender);
    }
    
    function setUserAccrualInterval(uint256 newInterval) public  {
        interestModule.setUserAccrualInterval(newInterval, msg.sender);
    }

    function getUserAccrualInterval() public view returns (uint256){
        return interestModule.getUserAccrualInterval(msg.sender);
    }

    function getAccountInterestRates() public view returns (uint256){
        return interestModule.getAccountInterestRates(msg.sender);
    }

    function distributeInterest(uint256 percentage, address toAccount) public  {
        if(interestModule.distributeInterest(percentage, toAccount, msg.sender)){
            payable(toAccount).transfer(interestModule.calculateInterest(msg.sender) * percentage / 100);
            payable(msg.sender).transfer(interestModule.calculateInterest(msg.sender) * (100 - percentage) / 100);
        }
        
    }

    function getAccountBalances() public view returns (uint256) {
        return interestModule.getAccountBalances(msg.sender);
    }

    //Interest Module --- End

}
