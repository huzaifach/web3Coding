//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Lottery2{

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

    // Generating a random no using a combination of block difficuly, timestamp & no of participants
    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    // Finally we pick a winner by choosing a random winner and paying the Prize Money to the winner
    //Then we reset the lottery
    function pickWinner() public{

        require(msg.sender == manager);
        require (participants.length >= 3);
        
        uint r = random();
        address payable winner;
        uint index = r % participants.length;
       
        winner = participants[index];
        winner.transfer(getBalance());
        participants = new address payable[](0);
    }

}