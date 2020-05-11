pragma solidity 0.5.8;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Registry.sol";
import "./Order.sol";
import "./lib/IERC20.sol";

contract Lucrum {
    using SafeMath for uint256;

    Registry public registry;

    uint256 public orderId = 0;
    mapping(uint256 => address) public orders;
    mapping(address => uint256[]) public userToOrderIds;

    constructor(Registry _registry) public {
        registry = _registry;
    }

    event LogOrderOpen(
        uint256 indexed orderId,
        address indexed orderAddr,
        uint256 returnAmount,
        address by
    );

    function open
    (
        address _srcToken,
        address _dstToken,
        uint256 _srcAmount,
        uint256 _triggerPrice,
        uint256 _expiryTime,
        bool _isBuy
    )
        public
        returns(uint256)

    {
        orderId = orderId.add(1);

        Order order = new Order(
            orderId,
            msg.sender,
            registry
        );

        IERC20(_srcToken).transferFrom(msg.sender, address(order), _srcAmount);

        uint256 returnAmount = order.init(
            _srcToken,
            _dstToken,
            _srcAmount,
            _triggerPrice,
            _expiryTime,
            _isBuy
        );
        
        orders[orderId] = address(order);
        userToOrderIds[msg.sender].push(orderId);

        emit LogOrderOpen(orderId, address(order), returnAmount, msg.sender);

        return orderId;
    }
}