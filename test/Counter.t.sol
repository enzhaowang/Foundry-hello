// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(1);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 2);
    }

    function test_Decrment() public {
        counter.decrement();
        assertEq(counter.number(), 0); // underflow wraps around
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
