//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {TokenBankAutomation} from "../../src/chainlink-automation/tokenBankAutomation.sol";
import {MyToken} from "../../src/chainlink-automation/MyToken.sol";


contract TokenBankAutomationTest is Test {
    MyToken mytoken;
    TokenBankAutomation bank;
    address ownerOfToken = address(0x1234);
    address ownerOfBank = address(0x2345);    

    function setUp() public {
        vm.startPrank(ownerOfToken);
        mytoken = new MyToken("MyToken", "MTK");
        vm.stopPrank();

        vm.startPrank(ownerOfBank);
        bank = new TokenBankAutomation(address(mytoken), 10 ether);
        vm.stopPrank();

        vm.startPrank(ownerOfToken);
        mytoken.approve(address(bank), 1000 ether);
        vm.stopPrank();

    }

    function test_upkeep_excessThreshold() public {
        vm.startPrank(ownerOfToken);
        bank.deposit(20 ether);

        (bool upKppNeeded, bytes memory data) = bank.checkUpkeep("");
        assertEq(upKppNeeded, true);

        //execute upkeep
        bank.performUpkeep(data);

        //verify token balance reduced
        uint256 bal = mytoken.balanceOf(address(bank));
        assertEq(bal, 0 ether);

        vm.stopPrank();
    }



}