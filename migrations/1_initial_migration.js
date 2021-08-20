const SAFULOCKFACTORY = artifacts.require("TimeLockedWalletFactory");

module.exports = function(deployer) {
    deployer.deploy(SAFULOCKFACTORY);
};