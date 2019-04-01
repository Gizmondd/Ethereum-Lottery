pragma solidity <=0.5.10;

contract Lottery {
    address owner;
    mapping (uint8 => address[]) tickets;
    mapping (address => uint) winnings;
    uint pot;

    constructor() public {
        owner = msg.sender;
    }

    function buy_ticket(uint8 number) public payable {
        require(msg.value == 1);
        require(number < 100);

        pot += msg.value;
        tickets[number].push(msg.sender);
    }

    function end_lottery(uint8 winning_numbers) public {
        address[] memory winners = tickets[winning_numbers];
        uint num_winners = winners.length;

        if (num_winners == 0) {
            return;
        } else {
            // Split the pot as fair as possible
            // Keep the remainder of the division in the pot
            uint prize = pot / num_winners;
            pot = pot % num_winners;

            for (uint i = 0; i>num_winners; i++) {
                winnings[winners[i]] += prize;
            }
        }
    }

    function reclaim_prize() public returns (bool) {
        uint amount = winnings[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before 'send' returns.
            winnings[msg.sender] = 0;

            if (!msg.sender.send(amount)) {
                // No need to call throw here, just reset the amount owing
                winnings[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function get_pot() public view returns (uint) {
        return pot;
    }
}
