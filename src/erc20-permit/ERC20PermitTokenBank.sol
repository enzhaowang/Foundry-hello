// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MyIERC20Permit} from "./MyIERC20Permit.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ERC20PermitTokenBank is Ownable{

    using SafeERC20 for MyIERC20Permit;

    /*
       Errors
    */
    error ZeroAmount();
    error InsufficientBalance();

    /*
      States
    */
    MyIERC20Permit public immutable token;
    mapping(address => uint256) private balances;
    uint256 public totalBalance;

    /**
     Events
    */
    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);


    /**
     Constructor
    */
    constructor(address token_, address owner) Ownable(owner) {
        require(token_ != address(0), "Token address can not be zero");
        token = MyIERC20Permit(token_);
    }


    /**
        user actions
    **/

    function deposit(uint256 amount) external {
        if(amount == 0) {
            revert ZeroAmount();
        }

        //transfer, need to approve first
        token.safeTransferFrom(msg.sender, address(this), amount);

        totalBalance += amount;
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);

    }


    /**
    deposit with signature
     */
    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if(amount == 0) {
            revert ZeroAmount();
        }

        //permit 
        token.permitAndTransferFrom(msg.sender, address(this), amount, deadline, v, r, s);
        totalBalance += amount;
        balances[msg.sender] += amount;
        emit Deposit(msg.sender, amount);
    }
    


    function withdraw(uint256 amount) external {
        if(amount == 0) revert ZeroAmount();
        if(amount > balances[msg.sender]) revert InsufficientBalance();

        balances[msg.sender] -= amount;
        totalBalance -= amount;
        
        token.safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    /**
        withdraw by owner
     */
    function ownerWithdraw(uint256 amount) external onlyOwner {
        if(amount == 0) revert ZeroAmount();
        if(amount > totalBalance) revert InsufficientBalance();

        totalBalance -= amount;

        token.safeTransfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }
    
    /*
    ########## views
    */

    function balanceOf(address user) external view returns(uint256 balance) {
        require(user != address(0), "address can not be 0");
        balance = balances[user];
    } 
}