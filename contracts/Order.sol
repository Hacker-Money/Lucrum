pragma solidity 0.5.8;

import "./Registry.sol";

contract Order {

    Registry public registry;

    struct OrderDetail {
        address srcToken;
        address dstToken;
        uint256 srcAmount;
        uint256 dstAmount;
        uint256 triggerPrice;
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
        // uint256 indexed currPrice,
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

        IERC20(detail.srcToken).approve(address(registry.aave()), detail.srcAmount);
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
        // require(detail.expiryTime > now, 'expired');

        // uint256 currPrice = registry.chainlink().getPrice(detail.srcToken);

        // if(!detail.isBuy) {
        //     require(detail.triggerPrice <= currPrice, 'invalid sell trigger');
        // } else {
        //     require(detail.triggerPrice >= currPrice, 'invalid buy trigger');
        // }
            
        detail.isExecuted = true;
        
        uint256 balance = registry.aave().balanceOf(address(this), detail.srcToken);

        address aToken = registry.aave().getAToken(detail.srcToken);

        IERC20(aToken).approve(address(registry.aave()), balance);
        uint256 redeemAmount = registry.aave().redeem(detail.srcToken, balance);

        uint256 dstAmount;
        //only for kovan network
        if(detail.srcToken == registry.bridge().AAVE_DAI()){
            IERC20(detail.srcToken).approve(address(registry.bridge()), redeemAmount);
            registry.bridge().up(redeemAmount);

            IERC20(registry.bridge().KYBER_DAI()).approve(address(registry.kyber()), redeemAmount);
            dstAmount = registry.kyber().trade(registry.bridge().KYBER_DAI(), detail.dstToken, redeemAmount);
        } else if(detail.dstToken == registry.bridge().AAVE_DAI()){
            IERC20(detail.srcToken).approve(address(registry.kyber()), redeemAmount);
            dstAmount = registry.kyber().trade(detail.srcToken, registry.bridge().KYBER_DAI(), redeemAmount);

            IERC20(registry.bridge().KYBER_DAI()).approve(address(registry.bridge()), dstAmount);
            registry.bridge().down(dstAmount);
        } else {
            IERC20(detail.srcToken).approve(address(registry.kyber()), redeemAmount);
            dstAmount = registry.kyber().trade(detail.srcToken, detail.dstToken, redeemAmount);
        }

        IERC20(detail.dstToken).approve(address(registry.aave()), dstAmount);
        registry.aave().lend(detail.dstToken, dstAmount);

        emit LogOrderExecuted(redeemAmount, dstAmount);
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

        address aToken = registry.aave().getAToken(detail.srcToken);
        IERC20(aToken).approve(address(registry.aave()), balance);
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

        address aToken = registry.aave().getAToken(detail.dstToken);
        IERC20(aToken).approve(address(registry.aave()), balance);
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