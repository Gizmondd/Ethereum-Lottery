pragma solidity <=0.5.10;


contract Lottery {
    address owner;
    mapping (uint => address payable[]) tickets;
    uint prize_pot;
    bool active;
    uint draw_time;
    uint blockNr;
    uint constant draw_count = 6;
    uint winning_number_sorted;

    constructor() public {
        owner = msg.sender;
        active = false;
    }
    
    // function get_prize_pot() view public returns(uint){
    //     return prize_pot;
    // }
    
    
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
        // if(blockNr > 0 && blockNr <= 256) { 
        //     if(block.number - blockNr > 0) { 
        //         blockNr = 0;
        //         return uint256(keccak256(block.blockhash(blockNr)));
        //     }
        // }
        uint num = uint(keccak256(abi.encodePacked(block.number, block.difficulty)))%(10**12);
        uint[draw_count] memory result_splitted = split(num);
        uint result = sort_and_merge(result_splitted);
        return result;
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
        require(msg.value > 1);

        prize_pot += msg.value;
        uint ticket_number_sorted = sort_and_merge(ticket_numbers); 
        
        tickets[ticket_number_sorted].push(msg.sender);
    }
    


    function end_lottery() public {
        require(active);
        require(now > draw_time);
        active = false;
        
        blockNr = block.number;
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
