// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
//import "./newNFT.sol";
contract SimpleAuction {

    address payable public beneficiary;
    uint public auctionEndTime;


    address public highestBidder;
    uint public highestBid;


    mapping(address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);


    constructor(uint _biddingTime,address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable{

            console.log("msg.value %s ", msg.value); 
    console.log("highestBid %s ", highestBid);

        require(block.timestamp <= auctionEndTime,"Auction already ended.");

        require(msg.value > highestBid,"There already is a higher bid.");

        if (highestBid != 0) {

            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }
    
    function getHighestBidder() public view returns(address,uint){
        return (highestBidder, highestBid);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {

            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
  
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }


    function auctionEnd() public {

        require(block.timestamp >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}