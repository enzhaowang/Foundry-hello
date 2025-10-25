// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import {Script} from "forge-std/Script.sol";
import {Bank} from "../src/bank-foundry/Bank.sol";


contract BankDeploy is Script{

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        new Bank();

        vm.stopBroadcast();
    }

}