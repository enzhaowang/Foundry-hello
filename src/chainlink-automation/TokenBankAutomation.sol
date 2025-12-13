//SPDX-License-Identifier: MIT


pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

//Chainlink Automation interface
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract TokenBankAutomation is AutomationCompatibleInterface {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public owner;
    uint256 public threshold;
    mapping(address => uint256) public deposits;

    event Deposited(address indexed user, uint256 amount);
    event TokensTransferred(address indexed to, uint256 amount);
    event ThresholdUpdated(uint256 newThreshold);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token, uint256 _threshold) {
        token = IERC20(_token);
        owner = msg.sender;
        threshold = _threshold;
    }

    /// user deposit token：need token.approve(bank, amount)
    function deposit(uint256 amount) external {
        require(amount > 0, "amount=0");
        deposits[msg.sender] += amount;
        token.safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "amount=0");
        uint256 bal = deposits[msg.sender];
        require(bal >= amount, "insufficient");
        deposits[msg.sender] = bal - amount;
        token.safeTransfer(msg.sender, amount);
    }

    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory)
    {
        bool hasBalance = token.balanceOf(address(this)) >= threshold;
        upkeepNeeded = hasBalance;
    }

    function performUpkeep(bytes calldata) external override {
        uint256 balance = token.balanceOf(address(this));
        bool hasBalance = (balance >= threshold);

    
        require(hasBalance, "Upkeep not needed");

        token.safeTransfer(owner, balance);
        emit TokensTransferred(owner, balance);
    }

    function updateThreshold(uint256 newThreshold) external onlyOwner {
        threshold = newThreshold;
        emit ThresholdUpdated(newThreshold);
    }

}