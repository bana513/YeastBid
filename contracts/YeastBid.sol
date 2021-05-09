// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

contract YeastBid {

  struct bids{
    uint amount;
    uint price;
  }

  //mapping is not iterable must store keys seperately
  mapping (address => uint256) private initial_bids;
  mapping (address => bids) public revealed_bids;

  //searchin in a list is very inefficient and costly, we store in mapping instead as a bool to see if an array contains an element
  //https://ethereum.stackexchange.com/questions/27510/solidity-list-contains/27518
  mapping (address => bool) private initial_bidders_helper;
  mapping (address => bool) public revealed_bidders_helper;

  address[] initial_bidders;
  address[] revealed_bidders;
  address[] accepted_bidders;

  uint blocks;
  uint start_time;
  uint life_time;
  address owner;
  uint8 phase;
  uint cum_sum;

  //sets the lifetime of phase 3 of contract
  constructor (uint _blocks, uint _life_time) {
    owner = msg.sender;
    blocks = _blocks;
    life_time = _life_time;
    phase = 0;
  }

  //phases:
  // 0: cant do nothing
  // 1: register hashes
  // 2: reveal hashes
  // 3: owner choses a set, and begins a timer
  function set_phase(uint8 _phase) public{
    //only owner can set phases, and only can move forward
    require(msg.sender == owner && _phase >= 0 && _phase < 3 && _phase > phase);
    phase = _phase;
  }

  //1 address can register only one bid
  function register_bid_hash(uint _hash) public{
    require(phase == 1);
    initial_bids[msg.sender] = _hash;
    if (!initial_bidders_helper[msg.sender]){
      initial_bidders_helper[msg.sender] = true;
      initial_bidders.push(msg.sender);
    }
  }

  //https://ethereum.stackexchange.com/questions/65076/match-web3py-hashing-function-to-solidity-hashing-function
  function hash_it(uint salt, uint quantity, uint price) public pure returns(uint) {
    return salt+quantity+price;
  }

  //
  function reveale_bids(uint salt, uint quantity, uint price) public{
    require(phase == 2 && initial_bids[msg.sender] == hash_it(salt,quantity,price));
    revealed_bids[msg.sender] = bids(quantity,price);
    if (!revealed_bidders_helper[msg.sender]){
      revealed_bidders_helper[msg.sender] = true;
      revealed_bidders.push(msg.sender);
    }
  }

  function final_phase(address[] memory _chosen_bids) public {
    require(phase == 2 && msg.sender == owner);

    uint amount = 0;
    cum_sum = 0;
    for (uint256 index = 0; index < accepted_bidders.length; index++) {
      cum_sum += revealed_bids[accepted_bidders[index]].amount*revealed_bids[accepted_bidders[index]].price;
      amount += revealed_bids[accepted_bidders[index]].amount;
    }

    require(amount < blocks);
    start_time = block.timestamp;
    accepted_bidders = _chosen_bids;
  }

  function disprove(address[] memory _chosen_bids) public {
    uint new_cum_sum = 0;
    uint new_amount = 0;
    for (uint256 index = 0; index < _chosen_bids.length; index++) {
      new_cum_sum += revealed_bids[_chosen_bids[index]].amount*revealed_bids[_chosen_bids[index]].price;
      new_amount += revealed_bids[_chosen_bids[index]].amount;
    }
    require( new_amount < blocks && cum_sum < new_cum_sum && block.timestamp < life_time+start_time);
    phase = 0;
    delete initial_bidders;
    delete revealed_bidders;
  }
}