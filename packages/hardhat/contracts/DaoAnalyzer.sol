
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DaoAnalyzer {

  IERC20 public token;

  uint256 public proposalCount;
  uint256 public votingThreshold;
  uint256 public proposalThreshold;


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

  constructor(address _tokenAddress) {
    token = IERC20(_tokenAddress);
    votingThreshold = 50;
    proposalThreshold = 100;
  }


  function createProposal(string memory _description) public {

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

  function executeProposal(uint _proposalId) public {
    Proposal storage proposal = proposals[_proposalId];
    require(proposal.creator != address(0), "Proposal does not exist");
    require(!proposal.executed, "Proposal has already been executed");

    uint totalVotes = proposal.yesVotes + proposal.noVotes;
    require(totalVotes > 0, "No votes cast for the proposal");

    require(proposal.yesVotes > proposal.noVotes, "Proposal did not pass");

    proposal.executed = true;

    emit ProposalExecuted(_proposalId, msg.sender);
  }

  function memberBalance(address _memberAddress) private view returns(uint256) {
    return token.balanceOf(_memberAddress);
  }

}