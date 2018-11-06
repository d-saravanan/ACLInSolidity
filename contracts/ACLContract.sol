pragma solidity ^0.4.24;

contract ACLContract {
	
	address public Owner;

	address[] public Users;

	/*
	* The Owner of the System is set as the one who is deploying the contract
	* This owner is thus set in the constructor itself as both the owner and the User
	*/
	constructor() {
		Owner = msg.sender;
		Users.push(Owner);
	}

	/*
	* Add a new user
	*/
	function Add(address userAddress) public returns (bool) {
		require(userAddress == Owner ,"Only Owner can add a new user");
		Users.push(userAddress);
		return true;
	}

	/*
	* Get the list of users in the system
	*/
	function getCount() public constant returns(uint) {
		return Users.length;
	}

	/*
	* Can the given user access the method
	* returns true if allowed, false otherwise
	*/
	function canUserAccess(address userAddress, string method) public returns (bool) {
		for(uint i = 0; i < Users.length; i++) {
			if(Users[i] == userAddress) {
				LogAccess(userAddress, now, method, "Authorization Successful");
				return true;
			}
		}
		LogAccess(userAddress, now, method, "Authorization Failed");

		return false;
	}

	event LogAccess(address indexed by, uint indexed accessTime, string method, string status);





}