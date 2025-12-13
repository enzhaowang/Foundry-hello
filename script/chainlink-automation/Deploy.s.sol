// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {TokenBankAutomation} from "../../src/chainlink-automation/tokenBankAutomation.sol";
import {MyToken} from "../../src/chainlink-automation/MyToken.sol";

contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("SEPOLIA_PRIVATE_KEY");
        vm.startBroadcast(pk);
        MyToken token = new MyToken("MyToken", "MTK");
        new TokenBankAutomation(address(token), 10 ether);
        vm.stopBroadcast();
    }
}

//bank contract 0xbca1A000F57911b5F4eE4087685C6aA70650c0A8
//0x312681543b97bdd2f698290b07070a35ec6aca7a7638b10acd5d20372db2e135
//mytoken contract 0x2B3AED34Cd25755595ABCfAD0bdBEaAf97111050
//0xcdbf389eeadcc606620a615f4214c0c1020d3dbc345e22ad095c17fdb2c439a1
