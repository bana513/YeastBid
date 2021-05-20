// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract YeastBid {

  struct bid{
    uint amount;
    uint price;
  }

  //mapping is not iterable must store keys seperately
  mapping (address => uint256) public initial_bids;
  mapping (address => bid) public revealed_bids;

  // Search in a list is very inefficient and costly, we store in mapping instead as a bool to see if an array contains an element
  // https://ethereum.stackexchange.com/questions/27510/solidity-list-contains/27518
  mapping (address => bool) private initial_bidders_helper;  // Helper to save addresses only once
  mapping (address => bool) public revealed_bidders_helper;

  // Create a mapping for accepted bidders to efficiently find unaccepted revealed bidders
  mapping (address => bool) private _accepted_bidders;

  address[] private initial_bidders;
  address[] public revealed_bidders;
  address[] public accepted_bidders;

  uint public blocks;  // Blocks of yeast
  uint public start_time;  // Phase 3's timestamp
  uint public life_time; // In seconds
  address public owner;
  uint8 public phase;
  uint public cum_sum;

  //sets the lifetime of phase 3 of contract
  constructor (uint _blocks, uint _life_time) {
    owner = msg.sender;
    blocks = _blocks;
    life_time = _life_time;
    phase = 0;
  }

  //phases:
  // 0: cant do anyhing
  // 1: register hashes
  // 2: reveal hashes
  // 3: owner choses a set, and begins a timer
  // 4: bidding ended
  function set_phase(uint8 _phase) public{
    //only owner can set phases, and only can move forward
    require(msg.sender == owner && _phase >= 0 && _phase <= 4 && _phase > phase, "You must be an owner and phase cannot be lower.");
    phase = _phase;
  }

  //1 address can register only one bid
  function register_bid_hash(uint _hash) public{
    require(phase == 1, "Not in bid registering phase.");
    initial_bids[msg.sender] = _hash;

    // Save bidder's address in list only once
    if (!initial_bidders_helper[msg.sender]){
      initial_bidders_helper[msg.sender] = true;
      initial_bidders.push(msg.sender);
    }
  }

  //https://ethereum.stackexchange.com/questions/65076/match-web3py-hashing-function-to-solidity-hashing-function
  function hash_it(uint salt, uint quantity, uint price) public pure returns(bytes32 result) {
    return keccak256(salt+quantity+price);
  }

  function reveale_bid(uint salt, uint quantity, uint price) public payable {
    require(phase == 2, "Not in bid revealing phase.");
    require(initial_bids[msg.sender] == hash_it(salt,quantity,price), "Wrong hash.");

    // Value of bids should be payed
    require(msg.value >= quantity * price, "Not enough payed.");

    revealed_bids[msg.sender] = bid(quantity,price);
    if (!revealed_bidders_helper[msg.sender]){
      revealed_bidders_helper[msg.sender] = true;
      revealed_bidders.push(msg.sender);
    }
  }

  function final_phase(address[] memory _chosen_bids) public {
    require(phase == 2 && msg.sender == owner, "Not in phase 2 or you are not an owner.");

    uint amount = 0;
    cum_sum = 0;
    for (uint256 index = 0; index < _chosen_bids.length; index++) {
      cum_sum += revealed_bids[_chosen_bids[index]].amount*revealed_bids[_chosen_bids[index]].price;
      amount += revealed_bids[_chosen_bids[index]].amount;
    }

    require(amount <= blocks);
    set_phase(3);
    start_time = block.timestamp;
    accepted_bidders = _chosen_bids;
  }

  function disprove(address[] memory _chosen_bids) public {
    require(phase == 3, "Not in dispoval phase.");

    if (block.timestamp >= life_time+start_time){
        // Bidding ended
        // No need for ownership
        phase = 4;
        pay_back();
    }

    uint new_cum_sum = 0;
    uint new_amount = 0;
    for (uint256 index = 0; index < _chosen_bids.length; index++) {
      new_cum_sum += revealed_bids[_chosen_bids[index]].amount*revealed_bids[_chosen_bids[index]].price;
      new_amount += revealed_bids[_chosen_bids[index]].amount;
    }
    require( new_amount < blocks && cum_sum < new_cum_sum);
    accepted_bidders = _chosen_bids;
  }

  function pay_back() public {
    require(phase == 4, "Can pay back only when bidding ended.");

    // Send the payed amount back to those who did not win
    for (uint256 index = 0; index < accepted_bidders.length; index++) {
        _accepted_bidders[accepted_bidders[index]] = true;
    }
    for (uint256 index = 0; index < revealed_bidders.length; index++) {
        if (!_accepted_bidders[revealed_bidders[index]]){
            payable(revealed_bidders[index]).transfer(
                revealed_bids[revealed_bidders[index]].amount * revealed_bids[revealed_bidders[index]].price // Does not handle overpayment
            );
        }
    }
  }

  function get_time() public view returns(uint) {
      return block.timestamp;
  }


  function get_revealed_bidders() public view returns(address[] memory) {
    return revealed_bidders;
  }

  function get_accepted_bidders() public view returns(address[] memory) {
    return accepted_bidders;
  }

}
