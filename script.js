let account;
let web3;
let contract;
let contractInterest;
const ABI =[
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "AccountArchived",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "AccountReactivated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "parent",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "child",
				"type": "address"
			}
		],
		"name": "ChildAccountAdded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "FundsAdded",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "parent",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "child",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "ModificationAccessGranted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "parent",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "child",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "ModificationAccessRevoked",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "Paused",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "age",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "ProfileModified",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "ScheduledTransferCancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "unlockTime",
				"type": "uint256"
			}
		],
		"name": "ScheduledTransferCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "ScheduledTransferExecuted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "ScheduledWithdrawCancelled",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "unlockTime",
				"type": "uint256"
			}
		],
		"name": "ScheduledWithdrawCreated",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "ScheduledWithdrawExecuted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "TransferExecuted",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [],
		"name": "Unpaused",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "UserLoggedIn",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "user",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "age",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"name": "UserRegistered",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "WithdrawalMade",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "SECONDS_IN_A_YEAR",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "accounts",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "balance",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "startTime",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "contractEndTime",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "parent",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "isChild",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "addFunds",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "addAmount",
				"type": "uint256"
			}
		],
		"name": "addInterestBalance",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_unlockTime",
				"type": "uint256"
			}
		],
		"name": "addScheduleWithdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_child",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amountWithdraw",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_unlockTime",
				"type": "uint256"
			}
		],
		"name": "addScheduleWithdrawForChild",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "archiveAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_index",
				"type": "uint256"
			}
		],
		"name": "cancelScheduleWithdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_index",
				"type": "uint256"
			}
		],
		"name": "cancelScheduledTransfer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "checkArchiveStatus",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "checkMyBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_child",
				"type": "address"
			}
		],
		"name": "checkTimeRemaining",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "children",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "userAddress",
				"type": "address"
			}
		],
		"name": "copyUserToAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "deductAmount",
				"type": "uint256"
			}
		],
		"name": "deductInterestBalance",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "deleteAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "executeAutoScheduledTransfers",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_index",
				"type": "uint256"
			}
		],
		"name": "executeScheduledWithdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAllScheduledTransfers",
		"outputs": [
			{
				"internalType": "address[]",
				"name": "receivers",
				"type": "address[]"
			},
			{
				"internalType": "uint256[]",
				"name": "amounts",
				"type": "uint256[]"
			},
			{
				"internalType": "uint256[]",
				"name": "unlockTimes",
				"type": "uint256[]"
			},
			{
				"internalType": "bool[]",
				"name": "activeStatuses",
				"type": "bool[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getAllTransferHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "receiver",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "amount",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct DepositAndWithdraw.TransferRecord[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_account",
				"type": "address"
			}
		],
		"name": "getArchiveTimestamp",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_parent",
				"type": "address"
			}
		],
		"name": "getChildren",
		"outputs": [
			{
				"internalType": "address[]",
				"name": "",
				"type": "address[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getCurrentBlockTimestamp",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_child",
				"type": "address"
			}
		],
		"name": "getParent",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "account",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "email",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "age",
						"type": "uint256"
					},
					{
						"internalType": "enum DepositAndWithdraw.AccountType",
						"name": "accountType",
						"type": "uint8"
					},
					{
						"internalType": "address",
						"name": "parent",
						"type": "address"
					},
					{
						"internalType": "enum DepositAndWithdraw.AccountStatus",
						"name": "status",
						"type": "uint8"
					},
					{
						"internalType": "uint256",
						"name": "archiveTimestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct DepositAndWithdraw.User",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getProfile",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "account",
						"type": "address"
					},
					{
						"internalType": "string",
						"name": "name",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "email",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "age",
						"type": "uint256"
					},
					{
						"internalType": "enum DepositAndWithdraw.AccountType",
						"name": "accountType",
						"type": "uint8"
					},
					{
						"internalType": "address",
						"name": "parent",
						"type": "address"
					},
					{
						"internalType": "enum DepositAndWithdraw.AccountStatus",
						"name": "status",
						"type": "uint8"
					},
					{
						"internalType": "uint256",
						"name": "archiveTimestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct DepositAndWithdraw.User",
				"name": "",
				"type": "tuple"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getTimeUntilDeletion",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_receiver",
				"type": "address"
			}
		],
		"name": "getTotalTransactionAmount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_index",
				"type": "uint256"
			}
		],
		"name": "getTransferDetails",
		"outputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user1",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "_user2",
				"type": "address"
			}
		],
		"name": "getTransferHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "sender",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "receiver",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "amount",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct DepositAndWithdraw.TransferRecord[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_user",
				"type": "address"
			}
		],
		"name": "getUserStatus",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_child",
				"type": "address"
			}
		],
		"name": "grantModificationAccess",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "instantTransfer",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_account",
				"type": "address"
			}
		],
		"name": "listScheduledWithdrawals",
		"outputs": [
			{
				"components": [
					{
						"internalType": "address",
						"name": "recipient",
						"type": "address"
					},
					{
						"internalType": "uint256",
						"name": "amount",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "unlockTime",
						"type": "uint256"
					},
					{
						"internalType": "bool",
						"name": "active",
						"type": "bool"
					}
				],
				"internalType": "struct DepositAndWithdraw.ScheduledWithdraw[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_account",
				"type": "address"
			}
		],
		"name": "listWithdrawals",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "amount",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					},
					{
						"internalType": "bool",
						"name": "isScheduled",
						"type": "bool"
					}
				],
				"internalType": "struct DepositAndWithdraw.Withdrawal[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_account",
				"type": "address"
			}
		],
		"name": "login",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_newAddress",
				"type": "address"
			}
		],
		"name": "migrateAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "modificationAccessGranted",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_email",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_age",
				"type": "uint256"
			}
		],
		"name": "modifyProfile",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "pause",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "paused",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "reactivateAccount",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "_email",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "_age",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_parent",
				"type": "address"
			},
			{
				"internalType": "enum DepositAndWithdraw.AccountType",
				"name": "_accountType",
				"type": "uint8"
			}
		],
		"name": "register",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_child",
				"type": "address"
			}
		],
		"name": "revokeModificationAccess",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_unlockTime",
				"type": "uint256"
			}
		],
		"name": "scheduleAutoExecution",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "scheduledTransfers",
		"outputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "unlockTime",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "active",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "scheduledWithdrawals",
		"outputs": [
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "unlockTime",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "active",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "transferHistory",
		"outputs": [
			{
				"internalType": "address",
				"name": "sender",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "receiver",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "unpause",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "users",
		"outputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "email",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "age",
				"type": "uint256"
			},
			{
				"internalType": "enum DepositAndWithdraw.AccountType",
				"name": "accountType",
				"type": "uint8"
			},
			{
				"internalType": "address",
				"name": "parent",
				"type": "address"
			},
			{
				"internalType": "enum DepositAndWithdraw.AccountStatus",
				"name": "status",
				"type": "uint8"
			},
			{
				"internalType": "uint256",
				"name": "archiveTimestamp",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_amount",
				"type": "uint256"
			}
		],
		"name": "withdraw",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "withdrawalHistory",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			},
			{
				"internalType": "bool",
				"name": "isScheduled",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
];
const ABIInterest = [
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_depositAndWithdrawAddress",
				"type": "address"
			}
		],
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "newInterval",
				"type": "uint256"
			}
		],
		"name": "AccrualIntervalChanged",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Deposit",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "interestAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "InterestAdd",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "interestAmount",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "to",
				"type": "address"
			}
		],
		"name": "InterestWithdrawn",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Withdraw",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "MONTHLY_INTERVAL",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "TESTING_INTERVAL",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "YEARLY_INTERVAL",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "accountBalances",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "accountInterestRates",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "addInterest",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "addInterestHistory",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interestAmount",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "balance",
				"type": "uint256"
			}
		],
		"name": "calculateInterest",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "value",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "deposit",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "percentage",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "toAccount",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "fromAccount",
				"type": "address"
			}
		],
		"name": "distributeInterest",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "interestDistributed",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interestWithdraw",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "distributionHistory",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interestAmount",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "getAccountBalances",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "getAccountInterestRates",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "getAddInterestHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "interestAmount",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "recipient",
						"type": "address"
					}
				],
				"internalType": "struct InterestModule.InterestHistory[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getContractBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getCurrentBlockTimestamp",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "getDistributionHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "interestAmount",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "recipient",
						"type": "address"
					}
				],
				"internalType": "struct InterestModule.InterestHistory[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "getLastInterestCalculationTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "contractAddress",
				"type": "address"
			}
		],
		"name": "getOtherContractBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "getUserAccrualInterval",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "user",
				"type": "address"
			}
		],
		"name": "getWithdrawalHistory",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "interestAmount",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "recipient",
						"type": "address"
					}
				],
				"internalType": "struct InterestModule.InterestHistory[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "startEpoch",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "endEpoch",
				"type": "uint256"
			}
		],
		"name": "interestCalculator",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "interfaceDepositAndWithdraw",
		"outputs": [
			{
				"internalType": "contract IDepositAndWithdraw",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "lastInterestCalculationTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "monthlyInterestRate",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "setFirstDeposit",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "newInterval",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "setUserAccrualInterval",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "testAccount",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "testingInterestRate",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "updateLastInterestCalculationTime",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "userAccrualIntervals",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "account",
				"type": "address"
			}
		],
		"name": "withdrawInterest",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "withdrawalHistory",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "interestAmount",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "yearIn30Seconds",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "yearlyInterestRate",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"stateMutability": "payable",
		"type": "receive"
	}
];


// Define the ABI and contract address globally
const Address = "0x341604dA1445683c04400C82d7957E9135e2f4cE";
const AddressInterest = "0xe19484d2d89E741b6E604eEEbc227736810E6CA4"; //Interest Module Addres

function showSection(sectionId) {
    const sections = document.querySelectorAll('.hidden-section');
    
    // Hide all sections
    sections.forEach(section => {
        section.style.opacity = 0;
        setTimeout(() => {
            section.style.display = 'none';
        }, 500);
    });

    const targetSection = document.getElementById(sectionId);
    
    if (targetSection) {
        setTimeout(() => {
            targetSection.style.display = 'block';
            setTimeout(() => targetSection.style.opacity = 1, 10);
        }, 500);
    }

    // Update the URL hash without reloading the page
    window.history.pushState(null, null, `#${sectionId}`);
}

// Connect MetaMask Wallet
async function connectWallet() {
    if (window.ethereum) {
        try {
            const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
            account = accounts[0];
            document.getElementById('navAddress').value = account;
            document.getElementById('account').innerText = account;
            web3 = new Web3(window.ethereum); // Instantiate web3 with MetaMask provider
            contract = new web3.eth.Contract(ABI, Address); // Instantiate the contract
            contractInterest = new web3.eth.Contract(ABIInterest, AddressInterest);
            fetchBalance();
            document.getElementById('account2').innerText = account;
            document.getElementById('account3').innerText = account;
        } catch (error) {
            console.error("User denied account access", error);
            // alert("Error connecting wallet. Check console for details.");
        }
    } else {
        alert("Please install MetaMask!");
    }
}


async function fetchBalance() {
    try {
        const balanceWei = await contract.methods.checkMyBalance().call({ from: account }); // Adjust according to your method
        const etherBalance = web3.utils.fromWei(balanceWei, 'ether');
        
        // Update all elements with the balanceResult class
        const balanceElements = document.querySelectorAll(".balanceResult");
        balanceElements.forEach(element => {
            element.innerText = `${etherBalance}`;
        });
    } catch (error) {
        console.error("Error fetching balance:", error);
    }
}


// Update the balance when the account changes (if applicable)
ethereum.on('accountsChanged', (accounts) => {
    account = accounts[0];
    document.getElementById('navAddress').value = account;
    document.getElementById('account').innerText = account;
    fetchBalance(); // Fetch balance again with the new account
});

window.addEventListener('load', connectWallet);
// Checking the balance
async function checkBalance() {
    try {
        const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
        const sender = accounts[0];

        contract.methods.checkMyBalance().call({ from: sender })
            .then((balance) => {
                const etherBalance = web3.utils.fromWei(balance, 'ether');
                querySelectorAll.getElementsByClassName('balanceResult').innerText = `${etherBalance}`;
				console.log(etherBalance);
                window.location.reload();
            })
            .catch((error) => {
                querySelectorAll.getElementsByClassName('balanceResult').innerText = `Error: ${error.message}`;
            });
    } catch (error) {
        querySelectorAll.getElementsByClassName('balanceResult').innerText = 'Please connect to MetaMask.';
    }
}

// Fetch and display the current block timestamp
// const getTimestamp = document.getElementById('accountDetails');
// getTimestamp.addEventListener('click', async () => {
//     try {
//         const timestamp = await contract.methods.getCurrentBlockTimestamp().call();
//         document.getElementById('timestampResult').innerText = `${timestamp}`;
//     } catch (error) {
//         document.getElementById('timestampResult').innerText = `Please connect to MetaMask`;
//     }
// });

// Handle checking time remaining
async function loadAccountTime() {
    try {
        if (typeof ethereum !== 'undefined') {
            const accounts = await ethereum.request({ method: "eth_requestAccounts" });
            const sender = accounts[0];

            // Assuming accountContract is already defined and initialized
            const profile = await contract.methods.getProfile().call({ from: sender });
            const age = profile.age;

            // Check if the user is 18 or older
            if (age >= 18) {
                document.getElementById('timeRemainingResult').innerText = "You Are Adult Now";
                document.getElementById('timeRemainingDiv').style.display = "none";
                document.getElementById('timeRemainingChild').style.display = "block";
                return; // Exit the function early if the user is 18 or older
            }else{
                document.getElementById('timeRemainingDiv').style.display = "block";
                document.getElementById('timeRemainingChild').style.display = "none";
            }

            // Calculate the time remaining until the user turns 18
            const yearsRemaining = 18 - age;
            const timeRemaining = yearsRemaining * 365 * 24 * 3600; // Convert years to seconds

            const days = Math.floor(timeRemaining / (3600 * 24)); // Convert seconds to days
            
            document.getElementById('timeRemainingResult').innerText = `${days} days until turning 18 years old.`;
        } else {
            alert("Please install MetaMask!");
        }
    } catch (error) {
        console.error("Error occurred:", error);
        document.getElementById('timeRemainingResult').innerText = "An error occurred while fetching the data.";
    }
};

// Function to set the amount when a button is clicked
function setAmount(value) {
    document.getElementById('amount').value = value;
}

// Add Funds to the contract
const addFundsForm = document.getElementById('addFundsForm');
addFundsForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const amount = document.getElementById('amount').value;
	const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
	sender = accounts[0];
	

    contract.methods.addFunds().send({
        from: sender,
        value: web3.utils.toWei(amount, 'ether')
    })
        .then((receipt) => {
            document.getElementById('fundsResponse').innerText = 'Funds added successfully!';
            // Check the balance after funds are successfully added
            checkBalance();
            window.location.reload();
        })
        .catch((error) => {
            document.getElementById('fundsResponse').innerText = `Error: ${error.message}`;
        });
		//Interest Module Code
		await contractInterest.methods.setFirstDeposit(sender).send({ from: sender });//Check is it first time deposit

});


// Function to set the amount when a button is clicked
function setWithdrawAmount(value) {
    document.getElementById('instantWithdrawAmount').value = value;
}
window.addEventListener('load', loadAccountTime);
window.addEventListener('load', connectWallet);
// Function to withdraw instantly
async function instantWithdraw() {
    const amount = document.getElementById('instantWithdrawAmount').value;

    if (amount > 0) {
        try {
            await contract.methods.withdraw(web3.utils.toWei(amount, 'ether')).send({ from: account });
            alert("Instant withdrawal successful!");
            checkBalance(); // Check balance after withdrawal
            window.location.reload();
        } catch (error) {
            console.error("Error withdrawing instantly:", error);
            alert("Error in instant withdrawal. Check console for details.");
        }
    } else {
        alert("Please enter a valid withdrawal amount.");
    }
}


async function getWithdrawals() {
    // Get the current account from Web3
    const accounts = await window.ethereum.request({ method: 'eth_accounts' });
    const accountAddress = accounts[0]; // Use the first account

    const withdrawalHistoryBody = document.getElementById('withdrawalHistoryBody');
    withdrawalHistoryBody.innerHTML = ""; // Clear previous results

    try {
        // Call the contract method to get withdrawals for the current account
        const withdrawals = await contract.methods.listWithdrawals(accountAddress).call();
        
        withdrawals.forEach((withdrawal, index) => {
            const row = withdrawalHistoryBody.insertRow();
            const indexCell = row.insertCell(0);
            const amountCell = row.insertCell(1);
            const dateCell = row.insertCell(2);
            
            indexCell.textContent = index + 1; // Index starts from 1
            amountCell.textContent = Web3.utils.fromWei(withdrawal.amount, 'ether'); // Convert from Wei to ETH and append " ETH"
            dateCell.textContent = new Date(withdrawal.timestamp * 1000).toLocaleString(); // Format timestamp
        });
    } catch (error) {
        console.error("Error fetching withdrawals:", error);
    }
}


async function listScheduledWithdrawals() {
    try {
        // Fetch the scheduled withdrawals from the contract
        const scheduledWithdrawals = await contract.methods.listScheduledWithdrawals(account).call();

        // Get the table body where the rows will be populated
        const tableBody = document.getElementById('withdrawalsBody');

        // Clear previous rows
        tableBody.innerHTML = '';

        // Loop through the scheduled withdrawals and populate the table
        scheduledWithdrawals.forEach((withdrawal, index) => {
            const amount = web3.utils.fromWei(withdrawal.amount, 'ether');  // Convert amount from Wei to ETH
            const unlockTime = new Date(withdrawal.unlockTime * 1000).toLocaleString();  // Convert UNIX timestamp to readable date
            const isActive = withdrawal.active ? 'Yes' : 'No';  // Check if withdrawal is still active

            // Create a new row for each scheduled withdrawal
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${index}</td>
                <td>${amount}</td>
                <td>${unlockTime}</td>
                <td>${isActive}</td>
            `;

            // Append the new row to the table body
            tableBody.appendChild(row);
        });
    } catch (error) {
        console.error("Error listing scheduled withdrawals:", error);
    }
}

async function ScheduleWithdraw() {
    try {
        if (typeof ethereum !== 'undefined') {
            const accounts = await ethereum.request({ method: "eth_requestAccounts" });
            const sender = accounts[0];

            // Assuming accountContract is already defined and initialized
            const profile = await contract.methods.getProfile().call({ from: sender });
            const age = profile.age;

            // Check if the user is 18 or older
            if (age >= 18) {
                document.getElementById('ScheduleWithdrawForm').style.display = "block";
                document.getElementById('NoChildScheduleWithdraw').style.display = "none";
                
                return; // Exit the function early if the user is 18 or older
            }else{
                document.getElementById('NoChildScheduleWithdraw').style.display = "block";
                document.getElementById('ScheduleWithdrawForm').style.display = "none";
            }
        } else {
            alert("Please install MetaMask!");
        }
    } catch (error) {
        console.error("Error occurred:", error);
        document.getElementById('timeRemainingResult').innerText = "An error occurred while fetching the data.";
    }
};

// Schedule withdrawal for the child account
async function addScheduleWithdraw() {
    const amount = document.getElementById('withdrawAmount').value;
    const datetimeInput = document.getElementById('withdrawDateTime').value;
    const date = new Date(datetimeInput);
    const unlockPeriod = Math.floor(date.getTime() / 1000); // Correctly getting the unlock time in seconds

    const timestamp = await contract.methods.getCurrentBlockTimestamp().call();

    if (amount > 0 && unlockPeriod > timestamp) {
        try {
            await contract.methods.addScheduleWithdraw(
                web3.utils.toWei(amount, 'ether'),
                unlockPeriod // Use the numeric unlockPeriod here
            ).send({ from: account });
            alert("Scheduled withdrawal successfully!");
            checkBalance();
            window.location.reload();
        } catch (error) {
            console.error("Error scheduling withdrawal:", error);
            alert("Error scheduling withdrawal. Check console for details.");
        }
    } else {
        alert("Please enter a valid amount and unlock period.");
    }
}

// Execute scheduled withdrawal
async function executeScheduledWithdraw() {
    const withdrawIndex = document.getElementById('withdrawIndex').value;
    if (withdrawIndex >= 0) {
        try {
            await contract.methods.executeScheduledWithdraw(withdrawIndex).send({ from: account });
            alert("Withdrawal executed successfully!");
        } catch (error) {
            console.error("Error executing withdrawal:", error);
            alert("Error executing withdrawal. Check console for details.");
        }
    } else {
        alert("Please enter a valid withdrawal index.");
    }
}

// Call the function when the child clicks a button, providing the correct index of the scheduled withdrawal


// Cancel Schedule Withdraw
const cancelWithdrawalForm = document.getElementById('cancelWithdrawalForm');
cancelWithdrawalForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const withdrawalIndex = document.getElementById('withdrawalIndex').value;
    const accounts = await web3.eth.getAccounts();
    const sender = accounts[0];

    contract.methods.cancelScheduleWithdraw(withdrawalIndex).send({
        from: sender
    })
        .then((receipt) => {
            document.getElementById('cancelResponse').innerText = `Scheduled withdrawal at index ${withdrawalIndex} canceled successfully.`;
        })
        .catch((error) => {
            document.getElementById('cancelResponse').innerText = `Error: ${error.message}`;
        });
});

async function ScheduleForChild() {
    try {
        if (typeof ethereum !== 'undefined') {
            const accounts = await ethereum.request({ method: "eth_requestAccounts" });
            const sender = accounts[0];

            // Assuming accountContract is already defined and initialized
            const profile = await contract.methods.getProfile().call({ from: sender });
            const age = profile.age;

            // Check if the user is 18 or older
            if (age >= 18) {
                document.getElementById('withdrawForm').style.display = "block";
                document.getElementById('nonParentMessageScheduleWIthdraw').style.display = "none";
                
                return; // Exit the function early if the user is 18 or older
            }else{
                document.getElementById('nonParentMessageScheduleWIthdraw').style.display = "block";
                document.getElementById('withdrawForm').style.display = "none";
            }
        } else {
            alert("Please install MetaMask!");
        }
    } catch (error) {
        console.error("Error occurred:", error);
        document.getElementById('timeRemainingResult').innerText = "An error occurred while fetching the data.";
    }
};


document.getElementById('withdrawForm').addEventListener('submit', async function (e) {
    e.preventDefault(); // Prevent form from submitting the default way

    const childAddress = document.getElementById('childAddress').value;
    const amount = document.getElementById('amountWithdraw').value;
    const unlockDate = document.getElementById('unlockTime').value;

    // Convert unlock date to Unix timestamp
    const unlockTimestamp = Math.floor(new Date(unlockDate).getTime() / 1000);

    // Convert amount to Wei (smallest Ether unit)
    const weiAmount = web3.utils.toWei(amount.toString(), 'ether');

    // Get the parent (the current connected account) from MetaMask
    const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    const parentAccount = accounts[0];

    

    try {
        await contract.methods.addScheduleWithdrawForChild(childAddress, weiAmount, unlockTimestamp)
            .send({ from: parentAccount });

        alert(`Scheduled withdrawal of ${amount} ETH for child ${childAddress}, to be unlocked on ${unlockDate}`);
    } catch (error) {
        console.error(error);
        alert('Error scheduling withdrawal. See console for details.');
    }
});

window.addEventListener('load', connectWallet);

    // Interest Module -- Start
    // Refresh account information
    // async function refreshAccountInfo() {
	// 	const accounts = await web3.eth.getAccounts();
	// 	const sender = accounts[0];
	// 	const balance = await contractInterest.methods.getAccountBalances(sender).call({ from: sender }); // Fixed accounts[0]
	// 	document.getElementById("account-balance").innerText = web3.utils.fromWei(balance, "ether") + " ETH";
	// 	// await contractInterest.methods.setFirstDeposit(sender).send({from: sender});//Check is it first time deposit
	// 	accrualInterval = await contractInterest.methods.getUserAccrualInterval(sender).call({ from: sender });
	// 	if (accrualInterval == 31536000) {
	// 	  accrualInterval = "Yearly";
	// 	} else if (accrualInterval == 2592000) {
	// 	  accrualInterval = "Monthly";
	// 	} else if (accrualInterval == 30) {
	// 	  accrualInterval = "Testing (30 seconds)";
	// 	}
	// 	document.getElementById("accrual-interval").innerText = accrualInterval;
  
	// 	const interestRate = await contractInterest.methods.getAccountInterestRates(sender).call({ from: sender });
	// 	document.getElementById("interest-rate").innerText = interestRate + "%";
	//   }

	async function refreshAccountInfo() {
		const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
		const sender = accounts[0];
	
		try {
			// Fetch balance
			const balance = await contractInterest.methods.getAccountBalances(sender).call({ from: sender });
			const balanceElements = document.getElementsByClassName("account-balance");
			for (let element of balanceElements) {
				element.innerText = web3.utils.fromWei(balance, "ether") + " ETH";
			}
	
			// Fetch accrual interval
			let accrualInterval = await contractInterest.methods.getUserAccrualInterval(sender).call({ from: sender });
			if (accrualInterval == 31536000) {
				accrualInterval = "Yearly";
			} else if (accrualInterval == 2592000) {
				accrualInterval = "Monthly";
			} else if (accrualInterval == 30) {
				accrualInterval = "Testing (30 seconds)";
			}
			const intervalElements = document.getElementsByClassName("accrual-interval");
			for (let element of intervalElements) {
				element.innerText = accrualInterval;
			}
	
			// Fetch interest rate
			const interestRate = await contractInterest.methods.getAccountInterestRates(sender).call({ from: sender });
			const interestRateElements = document.getElementsByClassName("interest-rate");
			for (let element of interestRateElements) {
				element.innerText = interestRate + "%";
			}
	
		} catch (error) {
			console.error("Error refreshing account info:", error);
		}
	}
	
  
	  // Calculate interest
  
	  function calculateInterest() {
		console.log("test");
		const calcAmount = document.getElementById("calc-amount").value;
		const amount = web3.utils.toWei(calcAmount, "ether");
		console.log(amount);
		const startTimes = document.getElementById("startTime").value;
		const endTimes = document.getElementById("endTime").value;
  
		// Convert to Date objects
		const startDate = new Date(startTimes);
		const endDate = new Date(endTimes);
  
		// Convert to epoch time in seconds
		const startEpoch = Math.floor(startDate.getTime() / 1000);
		const endEpoch = Math.floor(endDate.getTime() / 1000);

		if(endEpoch-startEpoch > 0){
			try {
				contractInterest.methods.interestCalculator(amount, startEpoch, endEpoch).call()
				  .then((result) => {
					document.getElementById("interest-test").innerText = web3.utils.fromWei(result[0], "ether") + " ETH";
					document.getElementById("interest-month").innerText = web3.utils.fromWei(result[1], "ether") + " ETH";
					document.getElementById("interest-year").innerText = web3.utils.fromWei(result[2], "ether") + " ETH";
				  })
				  .catch((error) => {
					console.error("Error calculating interest:", error);
				  });
			  } catch (error) {
				console.error("Error:", error);
			  }
		}else{
			document.getElementById("interest-test").innerText = "Invalid Date";
			document.getElementById("interest-month").innerText = "Invalid Date";
			document.getElementById("interest-year").innerText = "Invalid Date";
		}
		// console.log(startEpoch);
		// console.log(endEpoch);
  
		
	  }
  
  
	  //Add Interest
	  function addInterest() {
		ethereum.request({ method: 'eth_requestAccounts' }).then(async (accounts) => {
		  const sender = accounts[0];
  
		  try {
			// Call the contract to add interest
			const receipt = await contractInterest.methods.addInterest(sender).send({ from: sender });
  
			// Extract the interest amount from the emitted event
			const interestEvent = receipt.events.InterestAdd;
			const interestAmount = interestEvent.returnValues.interestAmount; // Extract the interest amount
  
			// Display success message
			document.getElementById("add-interest-status").innerText = "Interest added successfully!";
  
			// Call the main contract to update the interest balance with the extracted amount
			await contract.methods.addInterestBalance(sender, interestAmount).send({ from: sender });
  
		  } catch (error) {
			document.getElementById("add-interest-status").innerText = "Error adding interest.";
			console.error(error);
		  }
		}).catch((error) => {
		  console.error("Error requesting accounts:", error);
		});
	  }
  
  
  
  
  
	  function withdrawInterest() {
		ethereum.request({ method: 'eth_requestAccounts' }).then(async (accounts) => {
		  const sender = accounts[0];
  
		  try {
			// Call the contract to withdraw interest
			const interestDeduct = await contractInterest.methods.withdrawInterest(sender).send({ from: sender });
  
			// Check if interest has been successfully deducted and update the balance
			if (interestDeduct > 0) {
			  await contract.methods.deductInterestBalance(sender, interestDeduct).send({ from: sender });
			}
  
			// Display success message
			document.getElementById("withdraw-interest-status").innerText = "Interest withdrawn successfully!";
		  } catch (error) {
			// Display error message
			document.getElementById("withdraw-interest-status").innerText = "Error withdrawing interest.";
			console.error(error);
		  }
		}).catch((error) => {
		  console.error("Error requesting accounts:", error);
		});
	  }
  
  
	  function distributeInterest() {
		ethereum.request({ method: 'eth_requestAccounts' }).then(async (accounts) => {
		  const sender = accounts[0];
		  const percentage = document.getElementById("distribute-percentage").value;
		  const recipientAddress = document.getElementById("Recipient-Address").value;
		  
		  try {
			// Call the contract to distribute interest
			const result = await contractInterest.methods.distributeInterest(percentage, recipientAddress, sender).send({ from: sender });
  
			const interestDistributed = result[0];
			const interestWithdraw = result[1];
  
			// Deduct interest from the recipient's balance if applicable
			if (interestDistributed > 0) {
			  await contract.methods.deductInterestBalance(recipientAddress, interestDistributed).send({ from: sender });
			}
  
			// Deduct interest from the sender's balance if applicable
			if (interestWithdraw > 0) {
			  await contract.methods.deductInterestBalance(sender, interestWithdraw).send({ from: sender });
			}
  
			// Display success message
			document.getElementById("distribute-interest-status").innerText = "Interest distributed successfully!";
		  } catch (error) {
			// Display error message
			document.getElementById("distribute-interest-status").innerText = "Error distributing interest.";
			console.error(error);
		  }
		}).catch((error) => {
		  console.error("Error requesting accounts:", error);
		});
	  }
  
  
  
	  function changeAccrualInterval() {
		ethereum.request({ method: 'eth_requestAccounts' }).then(async (accounts) => {
		  const sender = accounts[0];
		  const selectedInterval = document.getElementById("interval-select").value;
  
		  try {
			console.log("test1");
			// Call the contract to set the user's accrual interval
			await contractInterest.methods.setUserAccrualInterval(selectedInterval, sender).send({ from: sender });
  
			// Display success message
			document.getElementById("change-interval-status").innerText = "Interval changed successfully!";
		  } catch (error) {
			// Display error message
			document.getElementById("change-interval-status").innerText = "Error changing interval.";
			console.error(error);
		  }
		}).catch((error) => {
		  console.error("Error requesting accounts:", error);
		});
	  }
  
  
  
  
	  // Get Interest History
	  async function getInterestHistory() {
		const accounts = await web3.eth.getAccounts();
		const sender = accounts[0];
		// console.log(sender);
  
		// Clear previous history display
		document.getElementById("withdrawal-history").innerHTML = '';
		document.getElementById("distribution-history").innerHTML = '';
		document.getElementById("add-interest-history").innerHTML = '';
  
		// Helper function to create table rows
		function createRow(item) {
		  const row = document.createElement("tr");
		  const interestInEther = web3.utils.fromWei(item.interestAmount.toString(), 'ether'); // Convert Wei to Ether
  
		  row.innerHTML = `
				  <td>${new Date(item.timestamp * 1000).toLocaleString()}</td>
				  <td>${interestInEther} ETH</td>
				  <td>${item.recipient}</td>
			  `;
		  return row;
		}
  
		// Get withdrawal history
		try {
		  const withdrawalHistory = await contractInterest.methods.getWithdrawalHistory(sender).call({ from: sender });
		  withdrawalHistory.forEach(item => {
			document.getElementById("withdrawal-history").appendChild(createRow(item));
		  });
		} catch (error) {
		  console.error("Error fetching withdrawal history:", error);
		}
  
		// Get distribution history
		try {
		  const distributionHistory = await contractInterest.methods.getDistributionHistory(sender).call({ from: sender });
		  distributionHistory.forEach(item => {
			document.getElementById("distribution-history").appendChild(createRow(item));
		  });
		} catch (error) {
		  console.error("Error fetching distribution history:", error);
		}
  
		// Get Add Interest history
		try {
		  const addInterestHistory = await contractInterest.methods.getAddInterestHistory(sender).call({ from: sender });
		  addInterestHistory.forEach(item => {
			document.getElementById("add-interest-history").appendChild(createRow(item));
		  });
		} catch (error) {
		  console.error("Error fetching add interest history:", error);
		}
	  }

	  function def() {
		const accounts =  web3.eth.getAccounts();
		const sender = accounts[0];
		contractInterest.methods.setFirstDeposit(sender).send({ from: sender });
	  }


  
	  // Interest Module -- End 
	

// Call this function when loading the page
window.addEventListener('load', displayTimeRemaining);

