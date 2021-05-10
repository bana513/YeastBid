const YeastBid = artifacts.require("YeastBid");

contract('YeastBid', (accounts) => {
    it("Deployable test", async () => {
        const contract = await YeastBid.deployed(
            10, // blocks of yeast
            120 // sec for phase 3
        );
        console.log(contract.address);
        assert(contract.address != "");
    });

    it("Initial Ganache amount test", async () => {
        account = accounts[1]
        console.log("Account #1: ", account);
        //const result = await my_contract.get_amount(); 
        let balance = await web3.eth.getBalance(account)
        console.log("Account #1 balance: ", balance);
        assert(balance == web3.utils.toWei('100', 'ether'), balance);
    });

    it("Successfull bidding", async () => {
        // Deployed from account[0]
        const contract = await YeastBid.deployed(
            10, // blocks of yeast
            120 // sec for phase 3
        );
        owner = accounts[0];
        bidder1 = accounts[1];
        bidder2 = accounts[2];
        
        console.log("bidder1: ", bidder1);

        // Start bidding
        contract.set_phase(1);

        // Make first bid
        _bid1_hash = await contract.hash_it.call(
            123,
            2,
            web3.utils.toWei('1', 'ether'),
            {from: bidder1}
        );
        const bid1_hash = _bid1_hash.toString();
        

        console.log("bid1_hash: ", bid1_hash);

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