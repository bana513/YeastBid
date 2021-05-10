const YeastBid = artifacts.require("YeastBid");


module.exports = function (deployer) {
  deployer.deploy(YeastBid, 10, 120);
};