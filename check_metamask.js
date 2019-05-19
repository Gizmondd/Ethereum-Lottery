'use strict';

// Check MetaMask

async function checkMetamask() {
  // Modern dapp browsers...
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
    try {
      // Request account access if needed
      await ethereum.enable();
      setErrorMessage("")
    } catch (error) {
      setErrorMessage("User denied access")
    }
  }
  // Legacy dapp browsers...
  else if (window.web3) {
    window.web3 = new Web3(web3.currentProvider);
  }
  // Non-dapp browsers...
  else {
    setErrorMessage('Non-Ethereum browser detected. You should consider trying MetaMask!')
  }
}
