pragma solidity 0.5.8;

interface ChainLink {
  function latestAnswer() external view returns (uint256);
}