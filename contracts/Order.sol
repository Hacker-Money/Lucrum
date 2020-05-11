pragma solidity 0.5.8;

import "./Registry.sol";

contract Order {

    Registry public registry;

    struct OrderDetail {
        address srcToken;
        address dstToken;
        uint256 srcAmount;
        uint256 dstAmount;
        uint256 triggerPrice; // match with chainlink
        uint256 startTime;
        uint256 expiryTime;
        bool isCancelled;
        bool isExecuted;
        bool isBuy;
    }

    uint256 public id;
    OrderDetail public detail;
    address public user;

    bool internal isInitC = false;


    event LogOrderCancel(
        uint256 indexed returnAmount
    );

    event LogOrderClose(
        uint256 indexed returnAmount
    );

    event LogOrderExecuted(
        uint256 indexed currPrice,
        uint256 redeemAmount,
        uint256 dstAmount
    );

    modifier initC() {
        require(isInitC, 'contract not initialised');
        _;
    }

    modifier notInitC() {
        require(!isInitC, 'contract initialised already');
        _;
    }

    modifier onlyUser() {
        require(user == msg.sender, 'invalid user');
        _;
    }

    modifier notCancelled() {
        require(!detail.isCancelled, 'order already cancelled');
        _;
    }

    modifier isCancelled() {
        require(detail.isCancelled, 'order is not cancelled');
        _;
    }

    modifier notExecuted() {
        require(!detail.isExecuted, 'order already executed');
        _;
    }

    modifier isExecuted() {
        require(detail.isExecuted, 'order is not executed');
        _;
    }

    constructor(
        uint256 _orderId,
        address _by,
        Registry _registry
    )
        public
    {
        id = _orderId;
        user = _by;
        registry = _registry;
    }

    function init(
        address _srcToken,
        address _dstToken,
        uint256 _srcAmount,
        uint256 _triggerPrice,
        uint256 _expiryTime,
        bool _isBuy
    )
        public
        notInitC
        returns (uint256)
    {
        detail = OrderDetail({
            srcToken : _srcToken,
            dstToken : _dstToken,
            srcAmount : _srcAmount,
            dstAmount : 0,
            triggerPrice : _triggerPrice,
            startTime : now,
            expiryTime : _expiryTime,
            isCancelled : false,
            isExecuted : false,
            isBuy : _isBuy
        });

        uint returnAmount = registry.aave().lend(detail.srcToken, detail.srcAmount);

        isInitC = true;

        return returnAmount;
    }

    function execute()
        public
        initC
        notCancelled
        notExecuted
    {
        uint256 currPrice = registry.chainlink().getPrice(detail.srcToken);

        if(detail.isBuy) {
            require(detail.triggerPrice <= currPrice, 'invalid buy trigger');
        } else {
            require(detail.triggerPrice >= currPrice, 'invalid sell trigger');
        }
            
        detail.isExecuted = true;
        
        uint256 balance = registry.aave().balanceOf(address(this), detail.srcToken);

        IERC20(detail.srcToken).approve(address(registry.aave()), balance);
        uint256 redeemAmount = registry.aave().redeem(detail.srcToken, balance);

        IERC20(detail.srcToken).approve(address(registry.kyber()), redeemAmount);
        uint256 dstAmount = registry.kyber().trade(detail.srcToken, detail.dstToken, redeemAmount);

        IERC20(detail.dstToken).approve(address(registry.aave()), dstAmount);
        registry.aave().lend(detail.dstToken, dstAmount);

        emit LogOrderExecuted(currPrice, redeemAmount, dstAmount);
    }

    function cancel()
        public
        initC
        onlyUser
        notCancelled
        notExecuted
    {
        detail.isCancelled = true;
        uint256 balance = registry.aave().balanceOf(address(this), detail.srcToken);

        IERC20(detail.srcToken).approve(address(registry.aave()), balance);
        uint256 returnAmount = registry.aave().redeem(detail.srcToken, balance);

        IERC20(detail.srcToken).transfer(user, returnAmount);

        emit LogOrderCancel(returnAmount);
    }

    function close()
        public
        initC
        onlyUser
        notCancelled
        isExecuted
    {
        uint256 balance = registry.aave().balanceOf(address(this), detail.dstToken);

        IERC20(detail.dstToken).approve(address(registry.aave()), balance);
        uint256 returnAmount = registry.aave().redeem(detail.dstToken, balance);

        detail.dstAmount = returnAmount;

        IERC20(detail.dstToken).transfer(user, returnAmount);
        emit LogOrderClose(returnAmount);
    }
    
    function balanceOf(bool isSrc)
        public
        view
        returns (uint256 _balance)
    {
        if(isSrc) {
            _balance = registry.aave().balanceOf(address(this), detail.srcToken);
        } else {
            _balance = registry.aave().balanceOf(address(this), detail.dstToken);
        }
    }


    function getDetail()
        public
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            detail.srcToken,
            detail.dstToken,
            detail.srcAmount,
            detail.dstAmount,
            detail.triggerPrice,
            detail.startTime,
            detail.expiryTime,
            detail.isCancelled
        );
    }


}