// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyNFT} from "../src/nft-market/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT public myNFT;
    address public owner = address(0x123);
    address public user = address(0x456);

    function setUp() public {
        vm.prank(owner);
        myNFT = new MyNFT();
    }

    function test_OwnerCanMint() public {
        vm.prank(owner);
        uint256 tokenId = myNFT.mintNFT(user, "ipfs://test");
        assertEq(myNFT.ownerOf(tokenId), user);
    }

    function test_Fail_NonOwnerCannotMint() public {
        vm.prank(user);
        myNFT.mintNFT(user, "ipfs://test");
    }

    function test_Fail_CannotMintToZeroAddress() public {
        vm.prank(owner);
        myNFT.mintNFT(address(0), "ipfs://test");
    }
}
