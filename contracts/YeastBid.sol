// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract YeastBid {
  address public owner;
  uint public amount;
  uint public bidding_phase_end;

  struct bid {
    uint amount;
    uint price;
  }

  mapping (address => uint256) private bid_hashes;
  mapping (address => bid) public accepted;

  uint public phase_number;
  uint256 public last_phase_start;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  modifier first_phase() {
    require(
      (bidding_phase_end > block.timestamp) && (phase_number == 1),
      "This function is restricted to first phase"
    );
    _;
  }

  modifier second_phase() {
    require(
      (bidding_phase_end < block.timestamp) && (phase_number == 2),
      "This function is restricted to second phase"
    );
    _;
  }

  modifier third_phase() {
    require(
      phase_number == 3,
      "This function is restricted to third phase"
    );
    _;
  }


  constructor (uint256 amount, uint bidding_phase_end) {
    owner = msg.sender;
    amount = amount;
    bidding_phase_end = bidding_phase_end;
    phase_number = 1;
  }

  function makeBid(uint256 _hash) public first_phase {
    bid_hashes[msg.sender] = _hash;
  }

  function revealBid(uint amount, uint price, uint256 salt) public second_phase {
    if (checkHash(msg.sender, amount, price, salt)){
      accepted[msg.sender] = bid(amount, price);
    }
  }

  function checkHash(address sender, uint amount, uint price, uint256 salt) private returns (bool) {
    // TODO
    return true;
  }

  function stopBidding() public restricted {
    phase_number = 2;

    evaluateBids();

    last_phase_start = block.timestamp;
  }

  function evaluateBids() private restricted {

  }
}
