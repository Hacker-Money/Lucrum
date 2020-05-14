const web3 = require('web3');
const assert = require('assert');

const KyberHandler = artifacts.require("KyberHandler.sol");
const ChainlinkHandler = artifacts.require("ChainlinkHandler.sol");
const AaveHandler = artifacts.require("AaveHandler.sol");
const AaveToKyberBridge = artifacts.require("AaveToKyberBridge.sol");
const Registry = artifacts.require("Registry.sol");
const Lucrum = artifacts.require("Lucrum.sol");
const WETH9 = artifacts.require("WETH9");
const IERC20 = artifacts.require("IERC20");
const Order = artifacts.require("Order");





contract('Lucrum', (accounts) => {
    console.log("<============ using account " + accounts[0] + " for deployment ============>");

    before( async() => {
        kyber = await KyberHandler.new("0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D");
        // bridge = await AaveToKyberBridge.new();
        bridge = {address:"0x2671F7f53D455713F609122eE341005A6E28379F"};
        chainlinkHandler = await ChainlinkHandler.new();
        // chainlink = {token_address:"0xd0A1E359811322d97991E03f863a0C30C2cF029C", oracle_address:"0xD21912D8762078598283B14cbA40Cb4bFCb87581"}
        // await chainlinkHandler.setOracle(chainlink.token_address, chainlink.oracle_address);
        aaveHandler = await AaveHandler.new("0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5", "0xd0A1E359811322d97991E03f863a0C30C2cF029C");
        registry = await Registry.new(aaveHandler.address, kyber.address, chainlinkHandler.address, bridge.address);
        // registry = {address:"0x4e2e2630cC3C499822c9cB4542dFee44B1E7813D"};
        lucrum = await Lucrum.new(registry.address);

    });

    it('Should console log kyber & chainlink address', async() =>{
        console.log("Kyber Addr: " + kyber.address);
        console.log("ChainLink Addr: " + chainlinkHandler.address);
        console.log("AaveHandler addr: " + aaveHandler.address);
        console.log("Registry Addr: " + registry.address);
        console.log("Lucrum Addr: " + lucrum.address);
        console.log("Bridge Addr: " + bridge.address);
    });

    // it('Should send the balance', async() => {
    //   var weth = await WETH9.at("0xd0A1E359811322d97991E03f863a0C30C2cF029C");
    //   let kyber = await KyberHandler.at("0xeD62189303892fa76B5151b770E889B7703AE1dd");
    //   let dai = "0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa";

    //   let amount = web3.utils.toWei("0.2", "ether");

    //   await weth.deposit({value: amount});
    //   await weth.approve(kyber.address, amount);
    //   await kyber.trade(weth.address, dai, amount);

    //     let dai1 = await IERC20.at("0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa");
    //     let balanceOf = await dai1.balanceOf(accounts[0]);
    //     let bridgeAddr = "0x2671F7f53D455713F609122eE341005A6E28379F";
    //     await dai1.transfer(bridgeAddr, balanceOf);
    // });

    // it('should deposit funds into aave', async() => {
    //   let lucrum = await Lucrum.at("0x05fF07Cb1B89dAF48C8D9e51BE9ec4A9174182db");
    //   let src_token = "0xd0a1e359811322d97991e03f863a0c30c2cf029c";
    //   let erc20 = await IERC20.at(src_token);
    //   let dst_dai = "0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD";
    //   let amount = web3.utils.toWei("0.001", "ether");
    //   // let price = 300*(Math.pow(10, 8));
    //   // let expiry = 2*(Math.pow(10, 10));
    //   var weth = await WETH9.at("0xd0A1E359811322d97991E03f863a0C30C2cF029C");
    //   // await weth.deposit({value: amount});
    //   await erc20.approve(lucrum.address, amount);
    //   await lucrum.open(src_token, dst_dai, amount, price, expiry, true);

    // });

    // it('should cancel the order', async() => {
    //     let order = await Order.at("0x5ff84ffb274850aa21fcc5b12f4f948440854966");
    //     await order.cancel();
    // });

    // it('should execute the order', async() => {
    //   let order = await Order.at("0xe4bb5568c67d0d8c26cb3ebc12d789e9d2325841");
    //   await order.execute();
    // });

    it('should withdraw funds', async() => {
      let order = await Order.at("0xe4bb5568c67d0d8c26cb3ebc12d789e9d2325841");
      await order.close();
    });

})