pragma solidity <=0.5.10;

contract Oracle {
    function generate_number(uint blocknumber) view public returns (uint) {
        return uint(keccak256(abi.encodePacked(blocknumber, block.difficulty)))%(10**12);
    }
}
