'use strict';

// Check MetaMask

async function check_metamask() {
  // Modern dapp browsers...
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
    try {
      // Request account access if needed
      await ethereum.enable();
      set_error_message("")
    } catch (error) {
      console.log("User denied access")
      set_error_message("User denied access")
    }
  }
  // Legacy dapp browsers...
  else if (window.web3) {
    window.web3 = new Web3(web3.currentProvider);
  }
  // Non-dapp browsers...
  else {
    console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    set_error_message('Non-Ethereum browser detected. You should consider trying MetaMask!')
  }
}
