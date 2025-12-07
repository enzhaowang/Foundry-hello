pragma solidity ^0.8.30;

contract BankWithLinkedDepositors {
    mapping(address => address) nextDepositor;
    mapping(address => uint256) balances;
    uint256 totalBalances;
    address immutable GUARD = address(0);
    
    constructor() {
        nextDepositor[GUARD] = GUARD;
    }

    function deposit(address prevDepositor, address oldPrevDepositor) public payable {
        require(msg.value > 0, "value cannot less than 0");
        if(nextDepositor[msg.sender] == address(0)) {
            addDepositor(prevDepositor, msg.sender, msg.value);
        } else {
            updateBalances(oldPrevDepositor, prevDepositor, msg.sender, balances[msg.sender] + msg.value);
        }
    }

    function withdraw(address prevDepositor, address oldPrevDepositor, uint256 value) public {
        require(balances[msg.sender] >= value, "insufficient balance");

        updateBalances(oldPrevDepositor, prevDepositor, msg.sender, balances[msg.sender] - value);
        (bool success, ) = address(msg.sender).call{value: value}('');
        require(success, 'transaction failed');

    }


    function addDepositor(address prevDepositor, address depositor, uint256 value) internal {
        require(nextDepositor[prevDepositor] != address(0));
        require(nextDepositor[depositor] == address(0));
        require(_verifyIndex(prevDepositor, value, nextDepositor[prevDepositor]));
        nextDepositor[depositor] = nextDepositor[prevDepositor];
        nextDepositor[prevDepositor] = depositor;
        balances[depositor] = value;
        totalBalances += value;
    }

    function updateBalances(address oldPrevDepositor, address newPrevDepositor, address depositor, uint256 value) internal {
        require(nextDepositor[oldPrevDepositor] != address(0));
        require(nextDepositor[newPrevDepositor] != address(0));
        require(nextDepositor[depositor] != address(0));
        
        if(oldPrevDepositor == newPrevDepositor) {
            require(_isPrevDepositor(oldPrevDepositor, depositor));
            require(_verifyIndex(oldPrevDepositor, value, depositor));
            uint256 originalBalance = balances[depositor];
            balances[depositor] = value;
            totalBalances = totalBalances + (value - originalBalance);
        } else {
            removeDepositor(oldPrevDepositor, depositor);
            addDepositor(newPrevDepositor, depositor, value);

        }
    }


    function removeDepositor(address prevDepositor, address depositor) internal {
        require(nextDepositor[prevDepositor] != address(0));
        require(nextDepositor[depositor] != address(0));
        require(_isPrevDepositor(prevDepositor, depositor));
        require(_verifyIndex(prevDepositor, balances[depositor], depositor));
        nextDepositor[prevDepositor] = nextDepositor[depositor];
        nextDepositor[depositor] = address(0);
        totalBalances  -= balances[depositor];
        balances[depositor] = 0;
        
    }

    function _isPrevDepositor(address prevDepositor, address depositor) internal view returns(bool) {
        return (
            nextDepositor[prevDepositor] == depositor
        );
    }

    function _verifyIndex(address prevDepositor, uint256 value, address nextDepositor) internal view returns(bool) {
        return (
            (prevDepositor == GUARD || value <= balances[prevDepositor]) &&
            (nextDepositor == GUARD || value > balances[nextDepositor])
        );
    }



}