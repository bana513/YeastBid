const YeastBid = artifacts.require("YeastBid");

contract('YeastBid', (accounts) => {
    it("Deployable test", async () => {
        const my_contract = await YeastBid.deployed(
            10, // blocks of yeast
            120 // sec for phase 3
        );
        console.log(my_contract.address);
        assert(my_contract.address != "");
    });

    it("Initial Ganache amount test", async () => {
        const my_contract = await YeastBid.deployed(
            10, // blocks of yeast
            120 // sec for phase 3
        );
        account = accounts[1]
        console.log("Account #1: ", account);
        //const result = await my_contract.get_amount(); 
        let balance = await web3.eth.getBalance(account)
        console.log("Account #1 balance: ", balance);
        assert(balance == web3.utils.toWei('100', 'ether'), balance);
    });

    
});

/*
contract('YeastBid', function(accounts) {
    var sb; // To store the instance when running

    // Test case 1
    it("Test initial balance", function() {
        return YeastBid.deployed(
            10, // blocks of yeast
            120 // sec for phase 3
        ).then(function(instance) {
            sb = instance;
            return sb.getBalance({ from: accounts[0] });
        }).then(function(x) {
            assert.equal(web3.utils.toWei('100', 'ether'), x, "Wrong initial balance");
        });
    });
});
*/