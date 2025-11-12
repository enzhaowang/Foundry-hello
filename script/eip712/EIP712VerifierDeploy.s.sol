// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {EIP712Verifier} from "../../src/eip712/EIP712Verifier.sol";

contract EIP712VerifierDeploy is Script {
    // Deployment logic for EIP712Verifier would go here
    function run() public {
        vm.startBroadcast(vm.envUint("SEPOLIA_PRIVATE_KEY"));

        new EIP712Verifier();

        vm.stopBroadcast();
    }
}

