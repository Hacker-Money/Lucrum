pragma solidity 0.5.8;

import "../lib/IERC20.sol";

//Just to use in Kovan
contract AaveToKyberBridge {
    address public AAVE_DAI = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address public KYBER_DAI = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;

    function up(uint256 _amount) public returns(uint256) {
        IERC20(AAVE_DAI).transferFrom(msg.sender, address(this), _amount);
        IERC20(KYBER_DAI).transfer(msg.sender, _amount);
        return _amount;
    }

    function down(uint256 _amount) public returns(uint256) {
        IERC20(KYBER_DAI).transferFrom(msg.sender, address(this), _amount);
        IERC20(AAVE_DAI).transfer(msg.sender, _amount);
        return _amount;
    }
}