pragma solidity <=0.5.10;

import "./oracle.sol";

contract Lottery {
    address payable owner;
    mapping (uint => mapping (uint => address payable[])) tickets;
    uint roundNumber;
    uint prizePot;
    bool active;
    bool ticketsClosed;
    uint drawTime;
    uint blockNr;
    uint constant drawCount = 6;
    uint[drawCount] winningNumbers;
    Oracle oracle;

    constructor(address _oracleAddress) public {
        owner = msg.sender;
        active = false;
        roundNumber = 0;
        oracle = Oracle(_oracleAddress);
    }

    function getRound() public view returns (uint){
        return roundNumber;
    }

    function getPot() public view returns (uint){
        return prizePot;
    }

    function getWinningNumbers() public view returns (uint[drawCount] memory){
        return winningNumbers;
    }

    function sort(uint[drawCount] memory ticketNumbers)
    public pure returns (uint[drawCount] memory)
    {
        for (uint i = 0; i<drawCount; i++){
            for (uint j = i+1; j<drawCount; j++){
                if (ticketNumbers[i]<ticketNumbers[j]){
                    uint256 tmp = ticketNumbers[i];
                    ticketNumbers[i] = ticketNumbers[j];
                    ticketNumbers[j] = tmp;
                }
            }

        }
        return ticketNumbers;
    }

    function merge(uint[drawCount] memory ticketNumbers) public pure returns (uint) {
        uint result = 0;
        for (uint i = 0; i<drawCount; i++) {
            result += ticketNumbers[i] * 100 ** i;
        }
        return result;
    }

    function split(uint256 num) public pure returns(uint[drawCount] memory){
        uint[drawCount] memory result;
        for (uint i = 0; i < drawCount; i++){
            result[i] = (num / 100 ** (drawCount - 1 - i)) % 100;
        }
        return result;
    }

    function getOracleNumbers() internal returns (uint) {
        winningNumbers = sort(split(oracle.generateNumber()));
        uint result = merge(winningNumbers);
        return result;
    }

    function startLottery(uint time) public {
        require(msg.sender == owner, "Not the owner");
        require(!active, "A lottery is still active");

        drawTime = block.timestamp + time;
        active = true;
        ticketsClosed = false;
    }

    function buyTicket(uint[drawCount] memory ticketNumbers) public payable {
        require(active, "No lottery is active at the moment");
        require(!ticketsClosed, "Tickets are not sold anymore");
        require(msg.value >= 400000000000000, "No money is sent");

        prizePot += msg.value;
        uint ticketNumberSorted = merge(sort(ticketNumbers));

        tickets[roundNumber][ticketNumberSorted].push(msg.sender);
    }

    function endLottery() public {
        require(block.timestamp > drawTime, "Too early to end the lottery");
        require(active, "No lottery is active at the moment");
        require(!ticketsClosed, "The lottery has already ended");

        // Stop ticket selling and save current block number

        ticketsClosed = true;
        blockNr = block.number;
    }

    function determineWinner() public {
        require(active);
        require(ticketsClosed, "The lottery is still active");
        require(blockNr != block.number, "Still on the same block");

        active = false;

        // Generate winning numbers based on new block number

        address payable[] memory winners = tickets[roundNumber][getOracleNumbers()];
        uint numWinners = winners.length;
        roundNumber += 1;

        if (numWinners != 0) {
            // Split the pot as fair as possible
            // Keep the remainder of the division in the pot
            uint prize = prizePot / numWinners;
            prizePot = prizePot % numWinners;

            for (uint i = 0; i<numWinners; i++) {
                winners[i].transfer(prize);
            }
            emit lotteryEnd(roundNumber, winningNumbers, winners, prize);
        } else {
            emit lotteryEnd(roundNumber, winningNumbers, winners, 0);
        }
    }

    event lotteryEnd(
        uint indexed roundNumber,
        uint[drawCount] winningNumbers,
        address payable[] winners,
        uint prize
    );

}
