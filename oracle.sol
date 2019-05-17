pragma solidity <=0.5.10;

contract Oracle {
    function generate_number() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.number, block.difficulty)))%(10**12);
    }
}
