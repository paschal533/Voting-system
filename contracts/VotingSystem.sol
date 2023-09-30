// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract VotingSystem is Ownable, ReentrancyGuard  {

    struct Candidate {
        string name;
        uint256 votes;
    }

    // Private state variables
    mapping(address => bool) private registeredVoters;
    mapping(address => bool) private hasVoted;
    mapping(address => Candidate) private candidates;
    address[] private candidateAddresses;
    uint256 private voteCount;

    // Events
    event VoterRegistered ( address voter );
    event CandidateRegistered ( address candidate, string name );
    event Vote ( address voter, string candidateName );

    // Modifier to check if an address is a registered voter
    modifier onlyVoter() {
      require(registeredVoters[msg.sender], "Only registered voters can access this function");
      _;
    }

    /**
     * Function to register new voter.
     *
     * @dev registerVoter() Registers new voter.
     * @param _voter - The address of the voter to be registered.
     * 
     */
    function registerVoter(address _voter) public onlyOwner {
        require(!registeredVoters[_voter], "Voter already registered");
        registeredVoters[_voter] = true;
        emit VoterRegistered(_voter);
    }

    /**
     * Function to Check if voter is registered.
     *
     * @dev checkRegisteredVoter() Check if voter is registered.
     * 
     * @return bool - true/false.
     */
    function checkRegisteredVoter(address _voter) public view returns (bool) {
        return registeredVoters[_voter];
    }

    /**
     * Function to register new candidate.
     *
     * @dev registerCandidate() Registers new candidate.
     * @param _name - The name of the candidate to be registered.
     * @param _candidateAddress - The address of the candidate to be registered.
     * 
     */
    function registerCandidate(string memory _name, address _candidateAddress) public onlyOwner {
        require(candidates[_candidateAddress].votes == 0, "Candidate already exists");
        candidates[_candidateAddress] = Candidate(_name, 0);
        candidateAddresses.push(_candidateAddress);
        emit CandidateRegistered(_candidateAddress, _name);
    }

    /**
     * Function to Check if Candidate is registered.
     *
     * @dev checkRegisteredCandidate() Check if Candidate is registered.
     * 
     * @return Candidate 
     */
    function checkRegisteredCandidate(address _Candidate) public view returns (Candidate memory) {
        return candidates[_Candidate];
    }

    /**
     * Function to Check if voter has voted.
     *
     * @dev checkHasVoted() Check if voter has votered.
     * 
     * @return bool - true/false.
     */
    function checkHasVoted(address _voter) public view returns (bool) {
        return hasVoted[_voter];
    }

    /**
     * Function for registered voters to cast their votes.
     *
     * @dev vote() Voters to cast their votes.
     * @param _candidateAddress - The address of the candidate to vote for.
     * 
     */
    function vote(address _candidateAddress) public onlyVoter {
        require(!hasVoted[msg.sender], "Already voted");
        require(candidates[_candidateAddress].votes >= 0, "Candidate does not exist");
        candidates[_candidateAddress].votes++;
        hasVoted[msg.sender] = true;
        voteCount++;
        emit Vote(msg.sender, candidates[_candidateAddress].name);
    }

    /**
     * Function to get each candidate vote count.
     *
     * @dev getCandidateVotes() Gets each candidate vote count.
     * @param _candidateAddress - The address of the candidate.
     * 
     * @return uint256 - The candidate vote count.
     */
    function getCandidateVotes(address _candidateAddress) public view returns (uint256) {
        return candidates[_candidateAddress].votes;
    }

   /**
    * Function to get the winning Candidate.
    *
    * @dev getWinningCandidate() - Gets the winning Candidate.
    * 
    * @return address - The winning candidate address.
    */
   function getWinningCandidate() public view returns (address) {
        require(candidateAddresses.length > 0, "No candidates available");

        address winningCandidateAddress = candidateAddresses[0];
        uint256 winningCandidateVotes = candidates[winningCandidateAddress].votes;

        for (uint256 i = 1; i < candidateAddresses.length; i++) {
            address candidateAddress = candidateAddresses[i];
            uint256 candidateVotes = candidates[candidateAddress].votes;
            if (candidateVotes > winningCandidateVotes) {
                winningCandidateAddress = candidateAddress;
                winningCandidateVotes = candidateVotes;
            }
        }
        return winningCandidateAddress;
   }

    /**
     * Function to retrieve the current vote count.
     *
     * @dev getVoteCount() - Gets the current vote count.
     * 
     * @return uint256 - The vote count.
     */
    function getVoteCount() public view returns (uint256) {
        return voteCount;
    }
}
