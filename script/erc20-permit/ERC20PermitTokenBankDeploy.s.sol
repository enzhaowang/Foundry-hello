// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import {Script} from "forge-std/Script.sol";
import {ERC20PermitTokenBank} from "../../src/erc20-permit/ERC20PermitTokenBank.sol";


contract MyERC20Deploy is Script{

    function run() public {
        vm.startBroadcast(vm.envUint("SEPOLIA_PRIVATE_KEY"));

        new ERC20PermitTokenBank(0x2eb6474FcDe25b1382f44972a29cF385d0CaC57D,vm.envAddress("SEPOLIA_PRIVATE_KEY_ADDRESS"));

        vm.stopBroadcast();
    }

}