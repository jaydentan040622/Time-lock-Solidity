// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Define the interface for DepositAndWithdraw
interface IDepositAndWithdraw {
    function accounts(address account) external view returns (
        uint256 balance,
        uint256 startTime,
        uint256 contractEndTime,
        address parent,
        bool isChild
    );
}
