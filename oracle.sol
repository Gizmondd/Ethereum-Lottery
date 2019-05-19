pragma solidity <=0.5.10;

contract Oracle {
    function generateNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.number, block.difficulty)))%(10**12);
    }
}
