const YeastBid = artifacts.require("YeastBid");

contract('YeastBid', () => {
    it("Deployable test", async () => {
        const my_contract = await YeastBid.deployed();
        console.log(my_contract.address);
        assert(my_contract.address != "");
    });

    //it("Amount test", async () => {
    //    const my_contract = await YeastBid.deployed();
    //    const result = await my_contract.get_amount(); 
    //    console.log(result);
    //    assert(result == 100,result);
    //});
});