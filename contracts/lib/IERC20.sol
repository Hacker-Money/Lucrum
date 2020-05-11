pragma solidity 0.5.8;

interface IERC20 {

    function decimals(
    )
        external
        view
        returns(uint256);
    
    function totalSupply(
    )
        external
        view
        returns (uint256);

    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);
    
    function allowance(
        address owner,
        address spender
    )
        external
        view
        returns (uint256);

    function transfer(
        address to,
        uint256 amount
    )
        external;
        
    function approve(
        address spender,
        uint256 amount
    )
        external;
    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        external;
    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
}