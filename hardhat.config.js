require("@nomiclabs/hardhat-waffle");
const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString();
const privateKey = fs.readFileSync(".secret").toString()
// const projectId = ""
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url:"https://speedy-nodes-nyc.moralis.io/929d047cebdaadb54ec8a581/polygon/mumbai",
      accounts:[]
    },
    mainnet: {
      url: "https://rinkeby.infura.io/v3/b2f38dd6fdef4888bb2b96c5aca98b62",
      accounts:[privateKey]
    },
    testnet: {
      url: "https://rinkeby.infura.io/v3/b2f38dd6fdef4888bb2b96c5aca98b62",
      accounts:[privateKey]
    }
  },
  solidity: "0.8.4",
};
