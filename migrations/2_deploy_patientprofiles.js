var PatientProfileContract = artifacts.require("./Patient.sol");

module.exports = function(deployer) {
  deployer.deploy(PatientProfileContract);
};
