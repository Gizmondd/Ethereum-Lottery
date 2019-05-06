'use strict';

// lottery namespace
var Lottery = {}

function buy_ticket() {
  update()
  var number_array = get_numbers()
  if (!number_array) {
    console.log("Invalid numbers")
    set_error_message("Invalid numbers")
    return;
  }
  set_error_message("")

  Lottery.contract_instance.buy_ticket.
  sendTransaction(number_array,
    {
      from: web3.eth.defaultAccount,
      gasPrice: "3000000",
      value: web3.toWei("10", "wei")
    },
    (error, transactionHash) =>{
      console.log("Transaction failed")
      console.log(error)
    })
}

function get_numbers() {
  var input_numbers = document.getElementsByClassName("inp_number")
  var number_array = []
  for (var i = 0; i<input_numbers.length; i++) {
    var next_number = parseInt(input_numbers[i].value)
    if (isNaN(next_number)) {
      return false;
    }
    number_array.push(next_number)
  }

  return number_array
}

function set_error_message(message) {
  Lottery.span_error_message.textContent = message
}

function init() {
  Lottery.btn_buy_ticket = document.getElementById("btn_buy_ticket")
  Lottery.inp_user_address = document.getElementById("inp_user_address")
  Lottery.inp_contract_address = document.getElementById("inp_contract_address")
  Lottery.span_error_message = document.getElementById("span_error_message")
  Lottery.btn_buy_ticket.addEventListener("click", buy_ticket)
}

function metamask_listener() {
  window.ethereum.on('accountsChanged', function() {
    update()
  })
  window.ethereum.on('networkChanged', function() {
    update()
  })
}

function update() {
  Lottery.contract_address = Lottery.inp_contract_address.value;
  Lottery.contract_instance = web3.eth.contract(lottery_abi).
    at(Lottery.contract_address)
  Lottery.contract_instance.defaultAccount = web3.eth.defaultAccount

  Lottery.inp_user_address.value = web3.eth.defaultAccount
  Lottery.inp_contract_address.value = Lottery.contract_instance.address
}

window.addEventListener('load', async () => {
  init()
  await check_metamask()
  metamask_listener()
  update()
})
