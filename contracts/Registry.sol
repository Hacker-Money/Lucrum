pragma solidity 0.5.8;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./handlers/KyberHandler.sol";
import "./handlers/ChainlinkHandler.sol";
import "./handlers/AaveHandler.sol";


contract Registry is Ownable {

    AaveHandler public aave;
    KyberHandler public kyber;
    ChainlinkHandler public chainlink;

    constructor(AaveHandler _aave,
        KyberHandler _kyber,
        ChainlinkHandler _chainlink
    )
        public
    {
        aave = _aave;
        kyber = _kyber;
        chainlink = _chainlink;
    }

}