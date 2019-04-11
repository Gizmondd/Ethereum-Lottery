pragma solidity <=0.5.10;

contract Oracle {
    uint constant draw_count = 6;
    function generate_number() public returns (uint[draw_count] memory);
}

contract Lottery {
    address owner;
    mapping (uint => address payable[]) tickets;
    uint prize_pot;
    bool active;
    uint draw_time;
    uint constant draw_count = 6;
    Oracle oracle;
    

    constructor(address _oracle) public {
        owner = msg.sender;
        active = false;
        oracle = Oracle(_oracle);
    }
    
    function start_lottery(uint time) public {
        require(msg.sender == owner);
        require(!active);
        
        draw_time = now + time;
        // tickets = empty??
        active = true;
    }

    function buy_ticket(uint[draw_count] memory ticket_numbers) public payable {
        require(active);
        require(msg.value == 1);

        prize_pot += msg.value;
        uint ticket_number_sorted = sort_and_combine(ticket_numbers); 
        
        tickets[ticket_number_sorted].push(msg.sender);
    }

    function end_lottery() public {
        require(active);
        require(now < draw_time);
        active = false;
        
        uint winning_number_sorted = sort_and_combine(oracle.generate_number());
        
        address payable[] memory winners = tickets[winning_number_sorted];
        uint num_winners = winners.length;

        if (num_winners == 0) {
            return;
        } else {
            // Split the pot as fair as possible
            // Keep the remainder of the division in the pot
            uint prize = prize_pot / num_winners;
            prize_pot = prize_pot % num_winners;

            for (uint i = 0; i<num_winners; i++) {
                winners[i].transfer(prize);
            }
        }
    }
    
    function sort_and_combine(uint[draw_count] memory ticket_numbers) internal pure returns (uint) {
        uint result = 0;
        for (uint i = 0; i<draw_count; i++) {
            result = ticket_numbers[i] * 100 ** i;
        }
        return result;
    }
}
