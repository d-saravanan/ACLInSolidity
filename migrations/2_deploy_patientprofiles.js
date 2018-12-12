var AccessControlContract = artifacts.require("./AccessControlContract.sol");

module.exports = function(deployer) {
  deployer.deploy(AccessControlContract);
};
