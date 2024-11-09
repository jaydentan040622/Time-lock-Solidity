// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Account {
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
        if (users[_user].accountType == AccountType.PARENT) {
            require(_age >= 18, "Parent's age cannot be below 18.");
        }
        _;
    }
    
    modifier accountActive(address _account) {
        require(users[_account].status == AccountStatus.ACTIVE, "Account is archived.");
        _;
    }

    function getUser(address user) public view returns (address, string memory, string memory, uint, AccountType, address, AccountStatus, uint) {
        User memory userInfo = users[user];
        return (
            userInfo.account,
            userInfo.name,
            userInfo.email,
            userInfo.age,
            userInfo.accountType,
            userInfo.parent,
            userInfo.status,
            userInfo.archiveTimestamp
        );
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
}   
