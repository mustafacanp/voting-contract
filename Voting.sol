
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Voting {
    uint8 public voterCount = 0;
    uint8 public votingLimit;
    bool public isVotingLimitEnabled;
    mapping(address => bool) alreadyVoted;
    string[] candidateNames;
    string[] pollingStations;
    address[] voters;

    mapping(string => Candidate) votesReceived;

    struct Candidate {
        string name;
        uint8 numberOfVotes;
        mapping(string => uint8) pollingStations;
    }

    constructor(
        string[] memory _candidateNames,
        string[] memory _pollingStations,
        address[] memory _voters,
        bool _isVotingLimitEnabled,
        uint8 _votingLimit
    ) {
        candidateNames = _candidateNames;
        pollingStations = _pollingStations;
        voters = _voters;
        isVotingLimitEnabled = _isVotingLimitEnabled;
        votingLimit = _votingLimit;
    }

    function getCandidateNames() public view returns (string[] memory) {
        return candidateNames;
    }

    function getPollingStations() public view returns (string[] memory) {
        return pollingStations;
    }

    function totalVotesForCandidate(string memory _candidate) public view returns (uint8) {
        require(validCandidate(_candidate), "Candidate name is not valid!");
        return votesReceived[_candidate].numberOfVotes;
    }

    function totalVotesForCandidateByPollingStation(
        string memory _candidate,
        string memory _pollingStation
    ) public view returns (uint8) {
        require(validCandidate(_candidate), "Candidate name is not valid!");
        require(validPollingStation(_pollingStation), "Polling station is not valid!");
        return votesReceived[_candidate].pollingStations[_pollingStation];
    }

    function voteForCandidate(string memory _candidate, string memory _pollingStation) public {
        if(isVotingLimitEnabled) require(voterCount < votingLimit, "Voting is over!");
        require(validCandidate(_candidate), "Candidate name is not valid!");
        require(validPollingStation(_pollingStation), "Polling station is not valid!");
        require(validVoter(msg.sender), "You are not a voter!");
        require(alreadyVoted[msg.sender] == false, "You have already voted!");
        votesReceived[_candidate].numberOfVotes++;
        votesReceived[_candidate].pollingStations[_pollingStation]++;
        alreadyVoted[msg.sender] = true;
        if(isVotingLimitEnabled) voterCount++;
    }

    function validCandidate(string memory _candidate) private view returns (bool) {
        for(uint i = 0; i < candidateNames.length; i++) {
            if (keccak256(abi.encodePacked(candidateNames[i])) == keccak256(abi.encodePacked(_candidate))) {
                return true;
            }
        }
        return false;
    }

    function validVoter(address _voter) private view returns (bool) {
        for(uint i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                return true;
            }
        }
        return false;
    }

    function validPollingStation(string memory _pollingStation) private view returns (bool) {
        for(uint i = 0; i < pollingStations.length; i++) {
            if (keccak256(abi.encodePacked(pollingStations[i])) == keccak256(abi.encodePacked(_pollingStation))) {
                return true;
            }
        }
        return false;
    }
}
