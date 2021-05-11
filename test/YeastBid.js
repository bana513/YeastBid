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
    

    it("Single bidder", async () => {
        owner = accounts[0];
        bidder = accounts[1];

        const contract = await YeastBid.deployed(
            10, // blocks of yeast
            120, // sec for phase 3
            { from: owner }
        );
        
        console.log("bidder: ", bidder);

        // Start bidding
        await contract.set_phase(1, { from: owner });

        // Make bid
        _bid_hash = await contract.hash_it.call(
            123,
            2,
            web3.utils.toWei('1', 'ether'),
            {from: bidder}
        );
        const bid_hash = _bid_hash.toString();
        console.log("bid_hash: ", bid_hash);
        await contract.register_bid_hash(bid_hash, { from: bidder });

        // Step into revealing phase
        await contract.set_phase(2, { from: owner });
        console.log("phase: ", (await contract.phase.call()).toString());

        // Reveal bid
        await contract.reveale_bid.call(
            123,
            2,
            web3.utils.toWei('1', 'ether'),
            {from: bidder, value: web3.utils.toWei('2', 'ether')}
        );
        console.log("reveale_bid called");
        
        console.log("Revealed bidders: ", await contract.get_revealed_bidders.call());

        // Step into final phase
        await contract.final_phase([bidder], { from: owner });
        console.log("phase: ", (await contract.phase.call()).toString());

        // Manually end contract
        await contract.set_phase(4, { from: owner });
        console.log("phase: ", (await contract.phase.call()).toString());

        // Check profit
        const profit = (await contract.cum_sum.call());
        console.log("profit: ", profit);

        assert.equal(web3.utils.toWei('2', 'ether'), profit, "Wrong profit");

    });

    
});