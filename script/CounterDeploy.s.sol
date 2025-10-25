pragma solidity ^0.8.13;
// SPDX-License-Identifier: UNLICENSED

import {Script} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterDeploy is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        // Deployment logic goes here
        new Counter();

        vm.stopBroadcast();
    }
}
