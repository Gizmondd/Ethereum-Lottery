# Ethereum-Lottery

Required:
i. https://metamask.io/
ii. https://truffleframework.com/ganache
iii. Install a web-server (e.g node or apache)

1. Start Ganashe > Quick start
2. remix.ethereum.org > run > Environment > web3 provider> Enter RPC: HTTP://127.0.0.1:7545 (from ganashe) > deploy (remix)
3. start metamask> set custom RPC> New Network: HTTP://127.0.0.1:7545
4. Start http server: e.g cd to index.html >  python -m http.server 8080 > 
5. browser: http://localhost:8080/index.html > click metamask ext> My account > Import account > past private key from ganashe (click on key to show)
6. Deplow contract in remix and copy adress of deployed contract
