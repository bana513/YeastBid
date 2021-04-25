const Migrations = artifacts.require("Migrations");
//var SimpleBank = artifacts.require("./SimpleBank.sol");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
