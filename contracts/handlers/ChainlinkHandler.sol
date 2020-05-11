pragma solidity 0.5.8;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "../lib/external/chainlink/ChainLink.sol";


contract ChainlinkHandler is Ownable {
    mapping(address => address) public oracles;

    function setOracle(address _tokenAddr, address _oracleAddr)
        public
        onlyOwner
    {
        oracles[_tokenAddr] = _oracleAddr;
    }

    function getPrice(address _tokenAddr) public view returns(uint256) {
        return uint256(ChainLink(oracles[_tokenAddr]).latestAnswer());
    }

}