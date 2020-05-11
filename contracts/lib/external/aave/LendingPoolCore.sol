pragma solidity 0.5.8;

interface LendingPoolCore {
  function getReserveATokenAddress(address _reserve) external view returns(address);
}