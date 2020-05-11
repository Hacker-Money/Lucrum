pragma solidity 0.5.8;

import "../../IERC20.sol";

interface KyberNetworkProxy {

    function maxGasPrice() external view returns(uint256);
    function getUserCapInWei(address user) external view returns(uint256);
    function getUserCapInTokenWei(address user, IERC20 token) external view returns(uint256);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint256);

    function swapTokenToToken(IERC20 src, uint256 srcAmount, IERC20 dst, uint256 minConversionRate) external returns(uint256);
    function swapEtherToToken(IERC20 token, uint256 minConversionRate) external payable returns(uint256);
    function swapTokenToEther(IERC20 token, uint256 srcAmount, uint256 minConversionRate) external returns(uint256);

    function getExpectedRate
    (
        IERC20 src,
        IERC20 dst,
        uint256 srcQty
    )
        external
        view
        returns
    (
        uint256 expectedRate,
        uint256 slippageRate
    );

    function tradeWithHint
    (
        IERC20 src,
        uint256 srcAmount,
        IERC20 dst,
        address dstAddress,
        uint256 maxdstAmount,
        uint256 minConversionRate,
        address walletId,
        bytes calldata hint
    )
        external
        payable
        returns(uint256);
}
