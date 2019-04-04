pragma solidity <=0.5.10;

contract Oracle {
    
  uint256[6] winning_number;

  function setNum(uint256[6] memory num) private {
      winning_number = num;
  }

  function getNum() public view returns (uint256[6] memory) {
      return winning_number;
  }

  function random() public {
      uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)))%(10**12);
      uint256[6] memory arr;
      for(uint256 i=0; i < 6; i++){
          arr[i] = num%100;
          num /= 100;
      }
      setNum(arr);
  }

}
