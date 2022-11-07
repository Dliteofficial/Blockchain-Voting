/*
Smart-Contract created by Dliteofficial
Date Created: 12 July 2022
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./DateTime.sol"; //importing the dateTime contract.

contract voting is DateTime{

    //Events
    event ProposalSubmitted (address owner, string aboutProposal, uint StartTime);
    event voteMade (address voter, VOTE choice);
    event endVotingChange (uint _endVoting);

    //Enums for singular option/selection
    enum VOTE {ACCEPT, REJECTED}
    VOTE choice;
    
    //Structs to collect Proposal Information.
    struct Proposal {
        address owner;
        string aboutProposal;
        uint StartTime;
        uint endTime;
        bool isCompleted;
        uint timeleft;
        uint totalVotes;
        mapping (address => Voter) voters; //mapping to access the Voter struct
    }

    //Struct to collec each voter's information.
    struct Voter {
        address voter;
        VOTE choice;
        mapping (address => bool) hasVoted;
    }

    //mapping to access the Proposal struct with the uint key type
    mapping (uint => Proposal) proposals;

    //variables
    uint proposalID;
    uint endVoting;
    uint voterCount = 1;

    //constructor to set the time required before a voting channel is closed...
    constructor (uint _days) {
        endVoting = _days * DAY_IN_SECONDS;
    }

    //function to submit proposal
    //It takes only one input - about the proposal -
    //Also emits information the proposal submitted event.
    function submitProposal (string memory _aboutProposal) public {
       proposals[proposalID].owner = msg.sender;
       proposals[proposalID].aboutProposal = _aboutProposal;
       proposals[proposalID].StartTime = block.timestamp;
       proposals[proposalID].endTime = proposals[proposalID].StartTime + endVoting;
       proposals[proposalID].timeleft = proposals[proposalID].endTime - block.timestamp;

       if (proposals[proposalID].StartTime < proposals[proposalID].endTime){
            proposals[proposalID].isCompleted = false;
        }
        proposalID++;

       emit ProposalSubmitted(msg.sender, _aboutProposal, block.timestamp); //fires the proposal submitted event
    }

    //function to get proposal details.
    //it takes the proposal ID as input to source for the proposal information
    //returns required information, basically, information the user needs to know.
    function getProposalDetails (uint _proposalID) public view returns (
        address owner,
        string memory aboutProposal,
        bool isCompleted,
        uint totalVotes
    ){
        (owner, aboutProposal, isCompleted, totalVotes) = (
            proposals[_proposalID].owner,
            proposals[_proposalID].aboutProposal,
            proposals[_proposalID].isCompleted,
            proposals[_proposalID].totalVotes
        );
    }

    //function allows you to vote on different proposals using the proposal ID and the enum vote index for accept or reject
    //also emits the vote made event.
    //it also records the voters information which is provided later
    function vote(uint _proposalID, VOTE _vote) public {
        require (!voteCompleted(_proposalID));
        require (proposals[_proposalID].voters[msg.sender].hasVoted[msg.sender] == false);
        proposals[_proposalID].voters[msg.sender].voter = msg.sender;
        proposals[_proposalID].voters[msg.sender].choice = _vote;
        proposals[_proposalID].voters[msg.sender].hasVoted[msg.sender] = true;
        voterCount++;
        proposals[_proposalID].totalVotes++;

        emit voteMade (msg.sender, _vote); //fires the vote made event
        }

    //function compiles the votes made for a particular proposal
    //it produces the number of accepted and rejected votes
    function compileVotes (uint _proposalID) public view returns (uint acceptedVotes, uint rejectedVotes) {
        uint count = 0;

        for (uint i = 1; i <= proposals[_proposalID].totalVotes; i++){
            if (proposals[_proposalID].voters[msg.sender].choice == VOTE.ACCEPT) {
                count++;
            }
        }
        acceptedVotes = count;
        rejectedVotes = proposals[_proposalID].totalVotes - acceptedVotes;
    }

    //checks to see if the voting for a proposal is still active
    function voteCompleted (uint _proposalID) public returns (bool complete) {
        if (block.timestamp >= proposals[_proposalID].endTime){
            complete = (proposals[_proposalID].isCompleted = true);
        }
    }

    //this function changes the time period required before the voting is concluded.
    //timeframe is initially set in the constructor...
    function changeEndVoting (uint _days) public {
        endVoting = _days*DAY_IN_SECONDS;

        emit endVotingChange (endVoting);
    }
}