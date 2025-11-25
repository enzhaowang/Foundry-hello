// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@permit2-light-sdk/sdk/IPermit2.sol";
import "@permit2-light-sdk/sdk/ISignatureTransfer.sol";

contract TokenBank is Ownable{

    using SafeERC20 for IERC20;

    /*
       Errors
    */
    error ZeroAmount();
    error InsufficientBalance();

    /*
      States
    */
    IERC20 public immutable token;
    mapping(address => uint256) private balances;
    uint256 public totalBalance;

    IPermit2 public immutable permit2;

    /**
     Events
    */
    event Deposit(address indexed user, uint amount);
    event Withdraw(address indexed user, uint amount);


    /**
     Constructor
    */
    constructor(address token_, address owner, address permit2_) Ownable(owner) {
        require(token_ != address(0), "Token address can not be zero");
        token = IERC20(token_);
        permit2 = IPermit2(permit2_);
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

    function depositWithPermit2(
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        bytes calldata signature
    ) external {
        require(amount > 0, "amount must be greater than 0");
    

        ISignatureTransfer.PermitTransferFrom memory permit = ISignatureTransfer.PermitTransferFrom({
            permitted: ISignatureTransfer.TokenPermissions({
                token: address(token),
                amount: amount
            }),
            nonce: nonce,
            deadline: deadline
        });

        //signature TransferDetails
        ISignatureTransfer.SignatureTransferDetails memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
            to: address(this),
            requestedAmount: amount
        });


        permit2.permitTransferFrom(permit, transferDetails, msg.sender, signature);


        balances[msg.sender] += permit.permitted.amount;        
        totalBalance += permit.permitted.amount;
        

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