const HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = "";

module.exports = {
  // Uncommenting the defaults below 
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
   development: {
    host: "127.0.0.1",
    port: 7545,
    network_id: "*"
   },
   kovan: {
    provider: new HDWalletProvider(MNEMONIC, `https://kovan.infura.io/v3/14a6144786774f5fbbad6c0ef7037b5f`),
    network_id: 42,      
    gas: 8000000,    
    gasPrice: 9000000000,    
    confirmations: 2,    
    timeoutBlocks: 200,  
    skipDryRun: true
   }
  //  ropsten: {
  //   provider: new HDWalletProvider('PVT_KEY', 'https://ropsten.infura.io/v3/4804d796d12a4a97a9e6a529552d9104'),
  //   network_id: 3,      
  //   gas: 8000000,    
  //   gasPrice: 9000000000,    
  //   confirmations: 2,    
  //   timeoutBlocks: 200,  
  //   skipDryRun: true
  //  },
  //  rinkeby: {
  //   provider: new HDWalletProvider(process.env.MNEMONIC, `https://rinkeby.infura.io/v3/${process.env.INFURA_KEY}`),
  //   network_id: 4,      
  //   gas: 6000000,    
  //   gasPrice: 9000000000,
  //   confirmations: 2,
  //   timeoutBlocks: 200,
  //   skipDryRun: true
  //  },
  //  mainnet: {
  //   provider: new HDWalletProvider(process.env.MNEMONIC, `https://mainnet.infura.io/v3/${process.env.INFURA_KEY}`),
  //   network_id: 1,
  //   gasPrice: 9000000000,
  //   confirmations: 2,
  //   timeoutBlocks: 200,
  //   skipDryRun: true
  //  }
  },
  mocha: {
    useColors: true
  },
  compilers: {
    solc: {
      version: "0.5.8",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        }
      },
      evmVersion: 'petersburg'
    }
  },
  plugins: ["solidity-coverage"]
};
