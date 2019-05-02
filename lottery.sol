pragma solidity <=0.5.10;


contract Lottery {
    address owner;
    mapping (uint => address payable[]) tickets;
    uint prize_pot;
    bool active;
    bool tickets_closed;
    uint draw_time;
    uint blockNr;
    uint constant draw_count = 6;
    uint winning_number_sorted;

    constructor() public {
        owner = msg.sender;
        active = false;
    }
    
    function split(uint256 num) pure public returns(uint[draw_count] memory){
        uint[draw_count] memory result;
        for(uint i=0; i < draw_count; i++){
            result[i] = num%100;
            num /= 100;
        }
        return result;
    }
    
    function sort_and_merge(uint[draw_count] memory ticket_numbers) pure public returns (uint) {
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
    
    function generate_number() view public returns (uint) {
        uint num = uint(keccak256(abi.encodePacked(block.number, block.difficulty)))%(10**12);
        uint[draw_count] memory result_splitted = split(num);
        uint result = sort_and_merge(result_splitted);
        return result;
    }

    
    function start_lottery(uint time) public {
        require(msg.sender == owner, "Not the owner");
        require(!active, "A lottery is already active");
        
        draw_time = now + time;
        // TODO: Empty tickets
        active = true;
        tickets_closed = false;
    }

    function buy_ticket(uint[draw_count] memory ticket_numbers) public payable {
        require(active, "No lottery is active at the moment");
        require(!tickets_closed, "Tickets are not sold anymore");
        require(msg.value > 1, "No money is sent");

        prize_pot += msg.value;
        uint ticket_number_sorted = sort_and_merge(ticket_numbers); 
        
        tickets[ticket_number_sorted].push(msg.sender);
    }
    


    function end_lottery() public {
        require(now > draw_time, "Too early to end the lottery");
        require(active, "No lottery is active at the moment");
        
        if (!tickets_closed) {
            // Stop ticket selling and save current block number
            
            tickets_closed = true;
            blockNr = block.number;
        } else if (blockNr != block.number) {
            active = false;
            // Executed when the transaction is on a new block
            
            // Generate winning numbers based on new block number
            winning_number_sorted = generate_number();
            
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
        
    }
}
