//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Lottery{

    // Declaring Required State Variables
    address payable[] public participants;
    address public manager;

    // Setting Contract Owner
    constructor(){
        manager = msg.sender;
    }

    // Receiving fees from Participants to join lottery
    receive () external payable{
        require(msg.value == 1 ether, "Please pay the exact fees");
        require(msg.sender != manager, "Manager can't be the Participant");
        participants.push(payable(msg.sender));
    }

    // Checking Contract Balance
    function getBalance() public view returns(uint){
        require(msg.sender == manager,"You are not the manager");
        return address(this).balance;
    }

    // Finally we pick a winner by choosing a random winner and paying the Prize Money to the winner
    //at last, we reset the lottery participants for another round
    function pickWinner() public{

        require(msg.sender == manager);
        require (participants.length >= 3);
        
        participants[uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, 
        participants.length))) % participants.length].transfer(address(this).balance);
        participants = new address payable[](0);
    }

}
