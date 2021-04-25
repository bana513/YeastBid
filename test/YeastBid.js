/*
var YeastBid = artifacts.require("YeastBid");

contract('YeastBid', function(accounts) {
    var sb; // To store the instance when running

    // Test case 1
    it("Test initial balance", function() {
        return SimpleBank.deployed().then(function(instance) {
            sb = instance;
            return sb.getBalance({ from: accounts[0] });
        }).then(function(x) {
            assert.equal(0, x, "Wrong initial balance");
        });
    });
});
*/