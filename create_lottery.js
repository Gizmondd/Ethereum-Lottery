'use strict';

// lottery namespace
var Lottery = {}

function setErrorMessage(message) {
  Lottery.spanErrorMessage.textContent = message
}

async function init() {
  Lottery.btnStartLottery = document.getElementById("btn_start_lottery")
  Lottery.btnStartLottery.addEventListener("click", startLottery)
  Lottery.btnEndLottery = document.getElementById("btn_end_lottery")
  Lottery.btnEndLottery.addEventListener("click", endLottery)
  Lottery.btnDetermineWinner = document.getElementById("btn_determine_winner")
  Lottery.btnDetermineWinner.addEventListener("click", determineWinner)

  Lottery.inpUserAddress = document.getElementById("inp_user_address")
  Lottery.inpContractAddress = document.getElementById("inp_contract_address")

  Lottery.spanErrorMessage = document.getElementById("span_error_message")

  await checkMetamask()
  Lottery.inpUserAddress.value = web3.eth.defaultAccount

  Lottery.abi = getLotteryABI()
}

// Updates the account/contract information and verifies the contract address and ticket numbers
function update() {
  // Update user account
  Lottery.inpUserAddress.value = web3.eth.defaultAccount

  // Update Contract
  if (!web3.isAddress(Lottery.inpContractAddress.value)) {
    setErrorMessage("Invalid contract address")
    return false;
  }
  Lottery.contractAddress = Lottery.inpContractAddress.value
  Lottery.contractInstance = web3.eth.contract(Lottery.abi).
    at(Lottery.contractAddress)
  Lottery.contractInstance.defaultAccount = web3.eth.defaultAccount;

  setErrorMessage("")
  return true
}

function startLottery() {
  if (!update()) { return }

  Lottery.contractInstance.startLottery.
  sendTransaction(10,
    {
      from: web3.eth.defaultAccount,
      gasPrice: "3000000"
    },
    (error, transactionHash) => {
      if (error) {setErrorMessage("Transaction failed")}
    })
}

function endLottery() {
  if (!update()) { return }

  Lottery.contractInstance.endLottery.
  sendTransaction(
    {
      from: web3.eth.defaultAccount,
      gasPrice: "3000000"
    },
    (error, transactionHash) => {
      if (error) {setErrorMessage("Transaction failed")}
    })
}

function determineWinner() {
  if (!update()) { return }

  Lottery.contractInstance.determineWinner.
  sendTransaction(
    {
      from: web3.eth.defaultAccount,
      gasPrice: "3000000"
    },
    (error, transactionHash) => {
      if (error) {setErrorMessage("Transaction failed")}
    })
}

window.addEventListener('load', async () => {
  init()
})
