pragma solidity ^0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'DistributorRole' to manage this role - add, remove, check
contract DistributorRole {
  using Roles for Roles.Role; //MZ ADDED

  // Define 2 events, one for Adding, and other for Removing
  event DistributorAdded(address indexed account);  //MZ ADDED
  event DistributorRemoved(address indexed account);  //MZ ADDED

  // Define a struct 'distributors' by inheriting from 'Roles' library, struct Role
  Roles.Role private distributors; //MZ ADDED

  // In the constructor make the address that deploys this contract the 1st distributor
  constructor() public {
    _addDistributor(msg.sender); //MZ ADDED
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyDistributor() {
    require(isDistributor(msg.sender)); //MZ ADDED
    _;
  }

  // Define a function 'isDistributor' to check this role
  function isDistributor(address account) public view returns (bool) {
    return distributors.has(account); //MZ ADDED
  }

  // Define a function 'addDistributor' that adds this role
  function addDistributor(address account) public onlyDistributor {
    _addDistributor(account); //MZ ADDED
  }

  // Define a function 'renounceDistributor' to renounce this role
  function renounceDistributor() public {
    _removeDistributor(msg.sender); //MZ ADDED
  }

  // Define an internal function '_addDistributor' to add this role, called by 'addDistributor'
  function _addDistributor(address account) internal {
    distributors.add(account); //MZ ADDED
    emit DistributorAdded(account); //MZ ADDED
  }

  // Define an internal function '_removeDistributor' to remove this role, called by 'removeDistributor'
  function _removeDistributor(address account) internal {
    distributors.remove(account); //MZ ADDED
    emit DistributorRemoved(account); //MZ ADDED
  }
}