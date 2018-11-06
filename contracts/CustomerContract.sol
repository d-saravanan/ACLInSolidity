pragma solidity ^0.4.24;

import "./ACLContract.sol";

contract CustomerContract is ACLContract {

	struct Customer {
		uint Id;
		string Name;
		uint DateOfBirth;
		uint Status;
	}

	uint constant Active = 1;
	uint constant Pending = 2;
	uint constant InActive = 3;

	//collection / hashmap for Customer
	mapping(uint => Customer) public Customers;

	uint _lastGeneratedCustomerId = 0;

	/*
	* Create a new customer
	*/
	function Create(string name, uint dateOfBirth, uint status) public returns(uint) {

		if(!canUserAccess(msg.sender, "Create")) throw;

		Customers[_lastGeneratedCustomerId] = Customer(_lastGeneratedCustomerId, name, dateOfBirth, status);

		_lastGeneratedCustomerId = _lastGeneratedCustomerId + 1;

		return _lastGeneratedCustomerId;
	}

	function Get(uint id) constant public returns ( uint customerId, string name, uint dateOfBirth, uint status) {
		if(!canUserAccess(msg.sender, "Get")) throw;
		
		Customer c = Customers[id];
		customerId = c.Id;
		name = c.Name;
		dateOfBirth = c.DateOfBirth;
		status = c.Status;
	}

	function Update(uint id, string name) public returns (bool) {
		if(!canUserAccess(msg.sender, "Update")) throw;
		Customers[id].Name = name;
		return true;
	}

	function UpdateCustomerStatus (uint id, uint status) public returns (bool) {
		if(!canUserAccess(msg.sender, "UpdateCustomerStatus")) throw;
		Customers[id].Status = status;
		return true;
	}

}