const { expect } = require('chai');
const { ethers } = require('hardhat');

// Define test suite
describe('VotingSystem', function () {
  let owner, voter1, voter2, voter3, candidate1, candidate2, votingSystem;

  // Before each test, deploy the contract and set up accounts
  beforeEach(async function () {
    [owner, voter1, voter2, voter3, candidate1, candidate2] = await ethers.getSigners();

    const VotingSystem = await ethers.deployContract('VotingSystem');
    votingSystem = await VotingSystem.waitForDeployment();
  });

  // Test voter registration
  it('should register a voter', async function () {
    await votingSystem.connect(owner).registerVoter(voter1.address);
    const isRegistered = await votingSystem.checkRegisteredVoter(voter1.address);
    expect(isRegistered).to.equal(true);
  });

  // Test candidate registration
  it('should register a candidate', async function () {
    await votingSystem.connect(owner).registerCandidate('Candidate 1', candidate1.address);
    const candidate = await votingSystem.checkRegisteredCandidate(candidate1.address);
    expect(candidate.name).to.equal('Candidate 1');
    expect(candidate.votes).to.equal(0);
  });

  // Test voting
  it('should allow a registered voter to cast a vote', async function () {
    await votingSystem.connect(owner).registerVoter(voter1.address);
    await votingSystem.connect(owner).registerCandidate('Candidate 1', candidate1.address);

    await votingSystem.connect(voter1).vote(candidate1.address);

    const candidateVotes = await votingSystem.getCandidateVotes(candidate1.address);
    expect(candidateVotes).to.equal(1);

    const hasVoted = await votingSystem.checkHasVoted(voter1.address);
    expect(hasVoted).to.equal(true);

    const voteCount = await votingSystem.getVoteCount();
    expect(voteCount).to.equal(1);
  });

  // Test for error when a non-registered voter tries to vote
  it('should revert when a non-registered voter tries to vote', async function () {
    await votingSystem.connect(owner).registerCandidate('Candidate 1', candidate1.address);
    await expect(votingSystem.connect(voter1).vote(candidate1.address)).to.be.revertedWith('Only registered voters can access this function');
  });

  // Test for error when a voter tries to vote twice
  it('should revert when a voter tries to vote twice', async function () {
    await votingSystem.connect(owner).registerVoter(voter1.address);
    await votingSystem.connect(owner).registerCandidate('Candidate 1', candidate1.address);

    await votingSystem.connect(voter1).vote(candidate1.address);

    await expect(votingSystem.connect(voter1).vote(candidate1.address)).to.be.revertedWith('Already voted');
  });

  // Test for getting the winning candidate
  it('should get the winning candidate', async function () {
    await votingSystem.connect(owner).registerVoter(voter1.address);
    await votingSystem.connect(owner).registerVoter(voter2.address);
    await votingSystem.connect(owner).registerVoter(voter3.address);
    await votingSystem.connect(owner).registerCandidate('Candidate 1', candidate1.address);
    await votingSystem.connect(owner).registerCandidate('Candidate 2', candidate2.address);

    await votingSystem.connect(voter1).vote(candidate1.address);
    await votingSystem.connect(voter2).vote(candidate2.address);
    await votingSystem.connect(voter3).vote(candidate2.address);

    const winningCandidateAddress = await votingSystem.getWinningCandidate();
    expect(winningCandidateAddress).to.equal(candidate2.address);
  });
});
