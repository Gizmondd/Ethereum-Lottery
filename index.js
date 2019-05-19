'use strict';

// lottery namespace
var Lottery = {}

function buyTicket() {
  // Check inputs
  if (!update()) { return }

  Lottery.contractInstance.buyTicket.
  sendTransaction(Lottery.numberArray,
    {
      from: web3.eth.defaultAccount,
      gasPrice: "3000000",
      value: web3.toWei("1", "ether")
    },
    (error, transactionHash) => {
      if (error) {
        setErrorMessage("Transaction failed")
      } else {
        setErrorMessage("")
      }
    })
}

// Get ticket numbers from input boxes
function getNumbers() {
  var inputNumbers = document.getElementsByClassName("inp_number")
  var numberArray = []
  for (var i = 0; i<inputNumbers.length; i++) {
    var nextNumber = parseInt(inputNumbers[i].value)
    if (isNaN(nextNumber)) {
      return false
    }
    numberArray.push(nextNumber)
  }

  return numberArray
}

function setErrorMessage(message) {
  Lottery.spanErrorMessage.textContent = message
}

async function init() {
  Lottery.btnBuyTicket = document.getElementById("btn_buy_ticket")
  Lottery.inpUserAddress = document.getElementById("inp_user_address")
  Lottery.inpContractAddress = document.getElementById("inp_contract_address")
  Lottery.spanErrorMessage = document.getElementById("span_error_message")
  Lottery.btnBuyTicket.addEventListener("click", buyTicket)
  Lottery.abi = getLotteryABI()

  await checkMetamask()
  Lottery.inpUserAddress.value = web3.eth.defaultAccount
}

// Updates the account/contract information and verifies the contract address and ticket numbers
function update() {
  // Update user account
  Lottery.inpUserAddress.value = web3.eth.defaultAccount

  // Update Contract
  if (!web3.isAddress(Lottery.inpContractAddress.value)) {
    setErrorMessage("Invalid contract address")
    return false
  }
  Lottery.contractAddress = Lottery.inpContractAddress.value
  Lottery.contractInstance = web3.eth.contract(Lottery.abi).
    at(Lottery.contractAddress)
  Lottery.contractInstance.defaultAccount = web3.eth.defaultAccount

  // Update numbers
  Lottery.numberArray = getNumbers()
  if (!Lottery.numberArray) {
    console.log("Invalid numbers")
    setErrorMessage("Invalid numbers")
    return false
  }

  // Check if event is already watched
  if (!Lottery.isWatching) {
    Lottery.isWatching = true;
    attachLotteryEndEvent()
  }
  setErrorMessage("")
  return true
}

function attachLotteryEndEvent() {
  // Attach endLottery event
  var lotteryEndEvent = Lottery.contractInstance.lotteryEnd()
  lotteryEndEvent.watch(function(error,result) {
    lotteryEndEvent.stopWatching()
    Lottery.isWatching = false;
    if (!error) {
      console.log(result)
      onEndLottery(result.args.roundNumber.toString(), result.args.winningNumbers, result.args.winners, result.args.prize.toString(),)
    } else {
      console.log(error)
    }
  })
}

function onEndLottery(roundNumber, winningNumbers, winnerList, prize) {
  var winCount = 0
  for (var index in winnerList) {
    if (web3.eth.defaultAccount === winnerList[index]) {
      winCount++
    }
  }

  // Convert array from bigNumber.js format
  var extractedNumbers = []
  for (var index = 0; index < winningNumbers.length; index++) {
    extractedNumbers.push(winningNumbers[index].toString())
  }

  console.log(prize)

  var myPrize = prize * winCount
  alert(`Lottery has ended\nWinning numbers: ${extractedNumbers}\nYou have won ${myPrize} Wei`)
}

window.addEventListener('load', async () => {
  init()
})
