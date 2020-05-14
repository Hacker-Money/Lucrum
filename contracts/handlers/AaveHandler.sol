pragma solidity 0.5.8;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "../lib/external/aave/LendingPoolAddressesProvider.sol";
import "../lib/external/aave/LendingPoolCore.sol";
import "../lib/external/aave/LendingPool.sol";
import "../lib/external/aave/AToken.sol";
import "../lib/WETH9.sol";
import "../lib/IERC20.sol";

contract AaveHandler {

    LendingPoolAddressesProvider public provider;
    WETH9 public weth9;
    address internal ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(LendingPoolAddressesProvider _provider, WETH9 _weth9)
        public
    {
        provider = _provider;
        weth9 = _weth9;
    }

    event LogLend(
        address indexed _tokenAddr,
        address indexed _lendTokenAddr,
        uint256 _amount,
        uint256 _lendTokenAmount
    );

    event LogRedeem(
        address indexed _tokenAddr,
        address indexed _lendTokenAddr,
        uint256 _amount,
        uint256 _lendTokenAmount
    );

    function balanceOf(address _addr, address _tokenAddr)
        public
        view
        returns (uint256)
    {
        address aToken = getAToken(_tokenAddr);
        return IERC20(aToken).balanceOf(_addr);
    }

    function getAToken(address _tokenAddr)
        public
        view
        returns (address)
    {
        address coreAddr = provider.getLendingPoolCore();

        address aToken;
        if(_tokenAddr != address(weth9)) {
            aToken = LendingPoolCore(coreAddr).getReserveATokenAddress(_tokenAddr);
        } else {
            aToken = LendingPoolCore(coreAddr).getReserveATokenAddress(ETH_ADDRESS);
        }
        return aToken;
    }

    function lend(address _tokenAddr, uint256 _amount)
        public
        returns (uint256 _lendTokenAmount)
    {

        IERC20(_tokenAddr).transferFrom(msg.sender, address(this), _amount);

        LendingPool lendingPool = LendingPool(provider.getLendingPool());

        address coreAddr = provider.getLendingPoolCore();

        if(_tokenAddr == address(weth9)) {
            weth9.withdraw(_amount);
        } else {
            IERC20(_tokenAddr).approve(coreAddr, _amount);
        }

        if(_tokenAddr != address(weth9)) {
            lendingPool.deposit(_tokenAddr, _amount, 0);
        } else {
            lendingPool.deposit.value(_amount)(ETH_ADDRESS, _amount, 0);
        }

        if(_tokenAddr != address(weth9)) {
            IERC20(_tokenAddr).approve(coreAddr, 0);
        }
        address aToken;
        if(_tokenAddr != address(weth9)) {
            aToken = LendingPoolCore(coreAddr).getReserveATokenAddress(_tokenAddr);
        } else {
            aToken = LendingPoolCore(coreAddr).getReserveATokenAddress(ETH_ADDRESS);
        }

        IERC20(aToken).transfer(msg.sender, _amount);

        _lendTokenAmount = _amount;

        emit LogLend(_tokenAddr, aToken, _amount, _amount);
    }

    function redeem(address _tokenAddr, uint256 _lendTokenAmount)
        public
        returns (uint256 _amount)
    {
        address coreAddr = provider.getLendingPoolCore();
        
        address aToken;
        if(_tokenAddr != address(weth9)) {
            aToken = LendingPoolCore(coreAddr).getReserveATokenAddress(_tokenAddr);
        } else {
            aToken = LendingPoolCore(coreAddr).getReserveATokenAddress(ETH_ADDRESS);
        }
        
        IERC20(aToken).transferFrom(msg.sender, address(this), _lendTokenAmount);

        AToken(aToken).redeem(_lendTokenAmount);

        if(_tokenAddr == address(weth9)) {
            _amount = address(this).balance;
            weth9.deposit.value(_amount)();
        } else {
            _amount = IERC20(_tokenAddr).balanceOf(address(this));
        }
        
        IERC20(_tokenAddr).transfer(msg.sender, _amount);

        emit LogRedeem(_tokenAddr, aToken, _amount, _lendTokenAmount);
    }

    function()
        external
        payable
    {
    }

}