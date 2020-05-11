pragma solidity 0.5.8;

interface LendingPool {
  function deposit ( address _reserve, uint256 _amount, uint16 _referralCode ) external payable;
}