pragma solidity ^0.4.24;

contract EntityPrivilegesContract {

	struct Entity {
		uint Id;
		string Name;
	}

	mapping(uint => string) private Entities;
	uint private _entityId = 0;

	mapping(uint => uint[]) public EntityPrivileges;

	function addEntity(string name) public returns (uint) {
		Entities[_entityId] = name;
		return _entityId++;
	}

	function addEntityPrivileges(uint entityId, uint[] privileges) public returns (bool) {
		//add require to validate the entity in the Entities collection
		EntityPrivileges[entityId] = privileges;
	}

	function getEntityPrivileges(uint entityId) public returns(uint[]) {
		return EntityPrivileges[entityId];
	}
}