// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/bank-foundry/Bank.sol";


contract BankTest is Test{
    Bank public bank;
    address owner = address(1010);
    address user = address(1);
    address user1 = address(2);
    address user2 = address(3);
    address user3 = address(4);
    address user4 = address(5);
    address user5 = address(6);




    function setUp() public {
        vm.startPrank(owner);
        bank = new Bank();
        vm.deal(address(this), 100 ether);
        vm.stopPrank();
    }


    function test_Deposit() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        assertEq(bank.balances(user), 0);
        bank.deposit{value: 1 ether}();
        vm.stopPrank();
        assertEq(bank.balances(user), 1 ether);

    }

    function test_TopDepositors() public {
        //test one person single depoit
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        bank.deposit{value: 1 ether}();
        (address[3] memory topDepositors, uint[3] memory topAmounts) = bank.getTopDepositors();
        assertEq(topDepositors[0], user);
        assertEq(topAmounts[0], 1 ether);
        vm.stopPrank();

        //test one person multiple deposit
        vm.deal(user1, 10 ether);
        vm.startPrank(user1);
        bank.deposit{value:1 ether}();
        bank.deposit{value:1 ether}();
        (topDepositors, topAmounts) = bank.getTopDepositors();
        assertEq(topDepositors[0], user1);
        assertEq(topDepositors[1], user);
        assertEq(topAmounts[0], 2 ether);
        assertEq(topAmounts[1], 1 ether);
        vm.stopPrank();
        
        //test 2 persons deposit
        vm.deal(user2, 10 ether);
        vm.startPrank(user2);
        bank.deposit{value:3 ether}();
        vm.stopPrank();

        vm.deal(user3, 10 ether);
        vm.startPrank(user3);
        bank.deposit{value:4 ether}();
        vm.stopPrank();

        (topDepositors, topAmounts) = bank.getTopDepositors();
        assertEq(topDepositors[0], user3);   
        assertEq(topDepositors[1], user2);
        assertEq(topDepositors[2], user1);
        assertEq(topAmounts[0], 4 ether);
        assertEq(topAmounts[1], 3 ether);
        assertEq(topAmounts[2], 2 ether);

        ////test 3 persons deposit
        vm.deal(user4, 10 ether);
        vm.startPrank(user4);
        bank.deposit{value:5 ether}();
        vm.stopPrank();

        vm.deal(user5, 10 ether);
        vm.startPrank(user5);
        bank.deposit{value:6 ether}();
        vm.stopPrank();

        (topDepositors, topAmounts) = bank.getTopDepositors();
        assertEq(topDepositors[0], user5);   
        assertEq(topDepositors[1], user4);
        assertEq(topDepositors[2], user3);
        assertEq(topAmounts[0], 6 ether);
        assertEq(topAmounts[1], 5 ether);
        assertEq(topAmounts[2], 4 ether);

    }


    function test_OnlyAdminCanWithdraw() public {
        bank.deposit{value:1 ether}();
        vm.deal(owner, 10 ether);
        uint256 bankBalance = address(bank).balance;
        vm.startPrank(owner);
        bank.withdraw();
        assertEq(address(bank).balance, 0);
        assertEq(owner.balance, bankBalance + 10 ether);
        vm.stopPrank();
    }

    function test_NotAdminCannotWithdraw() public {
        vm.deal(user, 10 ether);
        vm.startPrank(user);
        vm.expectRevert("Only owner can call this function");
        bank.withdraw();
        vm.stopPrank();
    }




}
