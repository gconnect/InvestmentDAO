

contract DaoAnalyzer {

  uint public proposalCount;

  mapping(uint => Proposal) public proposals;

  struct Proposal {
    address creator;
    string description;
    uint yesVotes;
    uint noVotes;
    bool executed;
    mapping(address => Vote) votes;
  }

  struct Vote {
    bool inSupport;
    bool voted;
  }

  event ProposalCreated(uint proposalId, address creator, string description);
  event Voted(uint proposalId, address voter, bool inSupport);
  event ProposalExecuted(uint proposalId, address executor);


  function createProposal(string memory _description) public {

  // TODO: Must have the nft to be able to create
  // TODO: Must have certain token amount

    proposalCount++;
    Proposal storage proposal = proposals[proposalCount];
    proposal.creator = msg.sender;
    proposal.description = _description;
    emit ProposalCreated(proposalCount, msg.sender, _description);
  }


  function vote(uint _proposalId, bool _inSupport) public {
    Proposal storage proposal = proposals[_proposalId];

    require(proposal.creator != address(0), "Proposal does not exist");
    require(!proposal.executed, "Proposal has already been executed");

    Vote storage _vote = proposal.votes[msg.sender];
    require(!_vote.voted, "Already voted");

    _vote.voted = true;
    _vote.inSupport = _inSupport;

    if (_inSupport) {
        proposal.yesVotes++;
    } else {
        proposal.noVotes++;
    }

    emit Voted(_proposalId, msg.sender, _inSupport);
  }

}