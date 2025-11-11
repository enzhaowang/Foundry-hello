// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TokenBank} from "../src/TokenBank.sol";

contract TokenBankDeploy is Script {
    TokenBank public tokenBank;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("SEPOLIA_PRIVATE_KEY"));

        tokenBank = new TokenBank(address(0x9b662D37a04a84Cb58B5846a2310b363b6D61b46), address(0x4aB1A869E9FB11F5E104222cF2fD5970B063A358));

        vm.stopBroadcast();
    }
}
