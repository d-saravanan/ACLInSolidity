pragma solidity ^0.4.24;

import "./RolePrivilegesContract.sol";

contract UserPrivilegesContract is RolePrivilegesContract {
	
	mapping(uint => uint[]) public UserRoles;

	function addRoleToUser(uint userId, uint roleId) public returns (bool) {
		UserRoles[userId].push(roleId);
		return true;
	}

	function getUserRoles(uint userId) public returns (uint[]) {
		return UserRoles[userId];
	}

	function checkUserRole(uint userId, uint roleId) returns (bool) {
		uint[] userRoles = UserRoles[userId];

		for(uint i = 0; i < userRoles.length; i++){
			if(userRoles[i] == roleId) return true;
		}
		return false;
	}

	function checkPermission(uint userId, uint permissionId) public returns (bool) {
		uint[] userRoles = UserRoles[userId];

		for(uint i = 0; i < userRoles.length; i++) {
			var permissions = getPermissions(userRoles[i]);
			for(uint j = 0; j < permissions.length; j++) {
				if(permissionId == permissions[j])
					return true;
			}
		}
		return false;
	}
}