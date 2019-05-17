pragma solidity <=0.5.10;

// Interface to Oracle SC
import "./oracle.sol";

contract Lottery {
    address payable owner;
    mapping (uint => mapping (uint => address payable[])) tickets;
    uint round_number;
    uint prize_pot;
    bool active;
    bool tickets_closed;
    uint draw_time;
    uint blockNr;
    uint constant draw_count = 6;
    uint winning_number_sorted;
    Oracle oracle;

    constructor(address _oracle_address) public {
        owner = msg.sender;
        active = false;
        round_number = 0;
        oracle = Oracle(_oracle_address);
    }

    function split(uint256 num) public pure returns(uint[draw_count] memory){
        uint[draw_count] memory result;
        for (uint i = 0; i < draw_count; i++){
            result[i] = (num / 100 ** (draw_count - 1 - i)) % 100;
        }
        return result;
    }

    function get_round() public view returns (uint){
        return round_number;
    }

    function get_Pot() public view returns (uint){
        return prize_pot;
    }

    function get_winningNumbers() public view returns (uint){
        return winning_number_sorted;
    }

    function sort_and_merge(uint[draw_count] memory ticket_numbers) public pure returns (uint) {
        uint result = 0;
        for (uint i = 0; i<draw_count; i++){
            for (uint j = i+1; j<draw_count; j++){
                if (ticket_numbers[i]<ticket_numbers[j]){
                    uint256 tmp = ticket_numbers[i];
                    ticket_numbers[i] = ticket_numbers[j];
                    ticket_numbers[j] = tmp;
                }
            }

        }
        for (uint i = 0; i<draw_count; i++) {
            result += ticket_numbers[i] * 100 ** i;
        }
        return result;
    }

    function get_oracle_number() public view returns (uint) {
        uint num = oracle.generate_number();
        uint[draw_count] memory result_splitted = split(num);
        uint result = sort_and_merge(result_splitted);
        return result;
    }

    function start_lottery(uint time) public {
        require(msg.sender == owner, "Not the owner");
        require(!active, "A lottery is still active");

        draw_time = block.timestamp + time;
        active = true;
        tickets_closed = false;
    }

    function buy_ticket(uint[draw_count] memory ticket_numbers) public payable {
        require(active, "No lottery is active at the moment");
        require(!tickets_closed, "Tickets are not sold anymore");
        require(msg.value > 1, "No money is sent");

        prize_pot += msg.value;
        uint ticket_number_sorted = sort_and_merge(ticket_numbers);

        tickets[round_number][ticket_number_sorted].push(msg.sender);
    }

    function end_lottery() public {
        require(block.timestamp > draw_time, "Too early to end the lottery");
        require(active, "No lottery is active at the moment");
        require(!tickets_closed, "The lottery has already ended");

        // Stop ticket selling and save current block number

        tickets_closed = true;
        blockNr = block.number;
    }

    function determine_winner() public {
        require(tickets_closed, "The lottery is still active");
        require(blockNr != block.number, "Still on the same block");

        active = false;

        // Generate winning numbers based on new block number
        winning_number_sorted = get_oracle_number();

        address payable[] memory winners = tickets[round_number][winning_number_sorted];
        uint num_winners = winners.length;
        round_number += 1;
        uint owner_share = prize_pot / 100;
        prize_pot -= owner_share;
        owner.transfer(owner_share);

        if (num_winners != 0) {
            // Split the pot as fair as possible
            // Keep the remainder of the division in the pot
            uint prize = prize_pot / num_winners;
            prize_pot = prize_pot % num_winners;

            for (uint i = 0; i<num_winners; i++) {
                winners[i].transfer(prize);
            }
        }
    }

}
