pragma solidity ^0.4.24;

contract EntityPrivilegesContract {

	struct Entity {
		uint Id;
		string Name;
	}

	mapping(uint => uint[]) public EntityPrivileges;
}