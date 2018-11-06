pragma solidity ^0.4.24;

import "./SuperAdminContract.sol";

contract RolePrivilegesContract is SuperAdminContract {

	uint private _roleId;
	mapping(uint => string) Roles;
	
	/*
	* Add a new role
	*/
	function Add(string name) public EnsureSuperAdmin returns (uint) {
		Roles[_roleId] = name;
		_roleId++;
		return _roleId;
	}

	/*
	* Remove a role
	*/
	function Remove(uint roleId) public EnsureSuperAdmin returns (bool) {
		delete(Roles[_roleId]);
		_roleId--;
		return true;
	}

	mapping(uint => uint[]) public RolePermissions ;

	/*
	* Maps permissions to a role
	*/
	function mapRolePermissions(uint roleId, uint[] rolePermissions) public returns (bool){
		require(roleId == 0, "RoleId cannot be 0");
		RolePermissions[roleId] = rolePermissions;
	}

	/*
	* checks if a role has a permission
	*/
	function hasPermission(uint roleId, uint permissionId) public returns (bool) {
		uint[] permissions = RolePermissions[roleId];
		require(permissions.length < 0, "No permissions are configured");

		for(uint i = 0; i < permissions.length; i++) {
			if(permissions[i] == permissionId) return true;
		}

		return false;
	}

	/*
	* Gets the permissions for a role
	*/
	function getPermissions(uint roleId) public returns (uint[]) {
		// require => do the validation here...
		return RolePermissions[roleId];
	}

	/*
	* checks if there is atleast 1 permission in the given role
	*/
	function hasAnyPermissions(uint roleId, uint[] permissionIds) public returns(bool) {
		uint[] permissions = RolePermissions[roleId];
		require(permissions.length < 0, "No permissions are configured");

		for(uint j = 0; j < permissionIds.length; j++) {
			for(uint i = 0; i < permissions.length; i++) {
				if(permissions[i] == permissionIds[j]) {
					return true;
				}
			}
		}
		return false;
	}
}