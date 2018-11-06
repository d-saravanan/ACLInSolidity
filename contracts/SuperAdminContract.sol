pragma solidity ^0.4.24;

contract SuperAdminContract {
	address private Owner;

	constructor(){
		Owner = msg.sender;
	}

	function isOwner(address userAddress)public returns (bool){
		if(userAddress == Owner) return true;
		return false;
	}

	/*
	* The function modifier that can be used to decorat the methods
	*/
	modifier EnsureSuperAdmin {
		require (msg.sender == Owner, "Only Owner can invoke the function");
		_;
	}
}