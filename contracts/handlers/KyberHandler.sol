pragma solidity 0.5.8;

import "../lib/external/kyber/KyberNetworkProxy.sol";
import "../lib/IERC20.sol";

contract KyberHandler {

    KyberNetworkProxy public kyber;

    constructor(KyberNetworkProxy _kyber)
        public
    {
        kyber = _kyber;
    }

    event LogTrade(
        address indexed _srcToken,
        address indexed _destToken,
        uint256 _srcAmount,
        uint256 _destAmount
    );


    function trade(
        address _srcToken,
        address _destToken,
        uint256 _srcAmount
    )
        external
        returns (uint256 _destAmount)
    {
        IERC20(_srcToken).transferFrom(msg.sender, address(this), _srcAmount);
        IERC20(_srcToken).approve(address(kyber), _srcAmount);

        uint256 slippageRate;
        (,slippageRate) = kyber.getExpectedRate(
            IERC20(_srcToken),
            IERC20(_destToken),
            _srcAmount
        );

        _destAmount = kyber.tradeWithHint(
            IERC20(_srcToken),
            _srcAmount,
            IERC20(_destToken),
            address(this),
            10**24,
            slippageRate,
            address(0),
            new bytes(0)
        );

        IERC20(_srcToken).approve(address(kyber), 0);
        IERC20(_destToken).transfer(msg.sender, _destAmount);

        emit LogTrade(_srcToken, _destToken, _srcAmount, _destAmount);
    }

}