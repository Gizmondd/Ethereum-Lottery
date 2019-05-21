# Ethereum-Lottery

Required:

i. https://metamask.io/

ii. https://truffleframework.com/ganache

iii. Install a web-server (e.g node or apache)

1. Start Ganache > Quick start
2. Start MetaMask > Set custom RPC > New Network: HTTP://127.0.0.1:7545 (Port from Ganache)
3. Open http://remix.ethereum.org > Compile lottery.sol and oracle.sol > Go to "run" tab > Select "Injected Web3"
4. Start http server: e.g cd to index.html >  python -m http.server 8080
5. Browser: http://localhost:8080/index.html > Click on MetaMask extension > My account > Import account > Copy private key from Ganache (click on key to show)
6. Deploy contract in Remix and copy address of deployed contract into the website
