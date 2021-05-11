# YeastBid
Blockchain bidding system in Solidity.

## Task description
At certain times, producers of yeast cannot keep up with user demand. Yeast is produced in large blocks 
of predetermined size; the producer decides to make extra profit regulate the market by accepting bids 
for a quantity (in grams) of yeast at some bidder-determined unit price (HUF/gram) from each large 
block of yeast. Bidding is performed in three phases. First, bidders register the hashes of their bids (salt + quantity + price). In the second phase, bidders register their bids (“reveal” them by showing the 
original content they registered the hash of). Third, the yeast producer registers the bids they accept 
and the bids they refuse. The accepted bids together must be an optimal (cumulatively, maximum 
financial value) solution to the packing-like problem of maximally covering the volume of the block of 
yeast with the bid-volumes. If any bidder can show a higher-value valid bid set within a predetermined 
time frame (thus proving that the yeast producer is not behaving fairly), the results are automatically 
invalidated, and the process starts again.  
Design and implement a smart contract that implements this bidding process.

## Clarification

Only the owner can change to the next phase, exept 3rd, 
where a timer set by the owner can also finish the phase.

Phases:  

0. Contract deployed, bidding not started.
1. Bidding started, hashes can be submited.
2. Bids' hash must be revealed to become valid. Cannot submit new hashes in this phase.
Users must deposit the required amount into the contract.
3. Owner choses a set of revealed bids. This might not be an optimal solution. Owner sets a timer.
Within given timeframe anyone can submit a new set of bids which are revealed and results more profit for the owner.
This way owner could outsource compute power. Users whose price might be lower than others, 
can provide candidate solutions for the NP hard problem. In case a more optimal solution is found,
this new set of bids becomes the new candidate for final set.
4. Contract ended.

## Documentation

### Public variables

```sol
uint public blocks;      // Blocks of yeast, set in constructor
uint public start_time;  // Start of phase #3, is set when owner calls set_phase(3)
address public owner;
uint8 public phase;
```
  
Phase #1:
```sol
mapping (address => uint256) public initial_bids;  // Hashes of bids
```

Phase #2:
```sol
struct bids{
	uint amount;
	uint price;
}
mapping (address => bids) public revealed_bids; 
mapping (address => bool) public revealed_bidders_helper;  // Is address's bid revealed
address[] public revealed_bidders;
```

Phase #3:
```sol
address[] public accepted_bidders;
uint public life_time;  // Timeout of phase #3 in seconds
uint public cum_sum;  // Current profit
```

### Functions
-
    ```sol
    constructor (uint _blocks, uint _life_time)
    ```
    Creates a contract.
    - *_blocks* - Amount of yeast
    - *_life_time* - Timeout for phase #3 in seconds.

-
    ```sol
    function set_phase(uint8 _phase) public
    ```
    Owner can change manually to next phase. 
    Phase #3 will can change manually as well.

-
    ```sol
    function hash_it(uint salt, uint quantity, uint price) public pure returns(uint)
    ```
    Simple hashing function, could be more complex to overcome the issue of a too simple salt.
    This function is used for revealing bid hashes, so submited hash should use the same algorithm 
    or should use this function to generate the hash.
    - *salt* - Should be random number to be completely fair in our simple algorithm.
    - *quantity* - Number of blocks of yeast.
    - *price* - Price for a block of yeast.

-
    ```sol
    function register_bid_hash(uint _hash) public
    ```
    Bids' hashes can be registered in phase #1. 
    Last submited hash will be registered from a given address.
    - *_hash* - Hash must be generated to be valid with contract's hashing function 
    when revealing it. 

-
    ```sol
    function reveale_bids(uint salt, uint quantity, uint price) public payable
    ```
    In phase #2 hashed should be revealed to become valid bids. 
    Parameters must match ones used for hash generation. 
    Total value of the bid should be payed with this transaction. 
    - *salt* - Should be random number to be completely fair in our simple algorithm.
    - *quantity* - Number of blocks of yeast.
    - *price* - Price for a block of yeast.

-
    ```sol
    function final_phase(address[] memory _chosen_bids) public
    ```
    Owner submits set of chosen bid, then a timer starts for phase #3. 
    - *_chosen_bids* - List of addresses from where the chosen bids where submited.

-
    ```sol
    function disprove(address[] memory _chosen_bids) public
    ```
    Anyone can a show a more optimal solution. 
    The set of bids generating the higher profit will remain.
    Owner can call this this function if want to.
    - *_chosen_bids* - List of addresses from where the chosen bids where submited.

-
    ```sol
    function pay_back() private
    ```
    Value of unchosen bids are repayed to their source addresses. 
    For simplicity overpayment is not handled, so be careful.


### Testing
1. Run Ganache -> Quickstart
2. 
    ```sh
    truffle test
    ```

### Tests
- *Deployable test*  
    Check if contract is deployable
- *Initial Ganache amount test*  
    Check if balance is equal to 100 ETH
- *Single bidder*  
    Check system with a single bidder - TEST FAILS!  
    However, it is working on Remix, so the test is not correct.
