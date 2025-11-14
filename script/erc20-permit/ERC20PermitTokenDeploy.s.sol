// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.3;

import {Script} from "forge-std/Script.sol";
import {ERC20PermitToken} from "../../src/erc20-permit/ERC20PermitToken.sol";


contract MyERC20Deploy is Script{

    function run() public {
        vm.startBroadcast(vm.envUint("SEPOLIA_PRIVATE_KEY"));

        new ERC20PermitToken(vm.envAddress("SEPOLIA_PRIVATE_KEY_ADDRESS"),1000 * 10 ** 18);

        vm.stopBroadcast();
    }

}