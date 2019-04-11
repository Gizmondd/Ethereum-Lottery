pragma solidity <=0.5.10;

contract Oracle {
    uint constant draw_count = 6;

    function generate_number() view public returns (uint[draw_count] memory) {
        uint num = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%(10**12);
        uint[draw_count] memory result;
        for(uint i=0; i < draw_count; i++){
            result[i] = num%100;
            num /= 100;
        }
        
        return result;
    }

}
