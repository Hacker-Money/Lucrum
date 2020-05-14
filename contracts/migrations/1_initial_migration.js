var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer, accounts) {
  // console.log("<============ using account " + accounts[0] + " for deployment ============>");
  deployer.deploy(Migrations);
};
