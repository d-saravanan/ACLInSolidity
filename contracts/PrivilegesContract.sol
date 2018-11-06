pragma solidity ^0.4.24;

import "./SuperAdminContract.sol";

contract PrivilegesContract is SuperAdminContract {
	
	struct Privilege {
		uint Id;
		string Name;
	}

	uint private privilegeId;
	mapping(uint => string) private Privileges;

	function Add(string name) public EnsureSuperAdmin returns (uint) {
		Privileges[privilegeId] = name;
		privilegeId = privilegeId +1;
		return privilegeId;
	}

	function Remove(uint id) public EnsureSuperAdmin returns (bool) {
		delete(Privileges[id]);
	}

	function getPrivilegeName(uint id) public EnsureSuperAdmin returns(string) {
		return Privileges[id];
	}
}