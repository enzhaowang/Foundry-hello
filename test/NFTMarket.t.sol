// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {NFTMarket} from "../src/nft-market/NFTMarket.sol";
import {MyERC20} from "../src/nft-market/MyERC20.sol";
import {MyNFT} from "../src/nft-market/MyNFT.sol";


contract NFTMarketTest is Test {
    
    NFTMarket public nftMarket;
    MyERC20 public paymentToken;
    MyNFT public myNFT;
    address public user = address(0x456);
    string public tokenURI = "ipfs://bafkreihgyyx4a5qsi4fxotxmqitngegzobmplmwzz4durcdkp3fokd6j24";

    event NFTListed(uint256 indexed listingId, address seller, address nftContract, uint256 tokenId, uint256 price);
    event NFTSold(uint256 indexed listingId, address seller, address indexed buyer, address nftContract, uint256 tokenId, uint256 price);
    
    function setUp() public {
        paymentToken = new MyERC20(1000000);
        nftMarket = new NFTMarket(address(paymentToken));
        myNFT = new MyNFT();
    }

    function test_ListNFT() public{
        vm.startPrank(user);
        myNFT.mintNFT(user, tokenURI);  //tokenId = 0
        vm.stopPrank();

        myNFT.mintNFT(address(this), tokenURI);  //tokenId = 1

        //check if price is bigger than 0
        vm.expectRevert("Price can not be set to 0");
        nftMarket.list(address(myNFT), 0, 1);

        //check if nft contract address is zero
        vm.expectRevert("nft contract address can not be 0");
        nftMarket.list(address(0), 100, 1);


        //check if caller is owner of nft
        vm.expectRevert("You are not the owner");
        nftMarket.list(address(myNFT), 100, 0);

        //list the NFT
        myNFT.approve(address(nftMarket), 1);
        vm.expectEmit(true, true, false, true);
        emit NFTListed(0, address(this), address(myNFT), 1, 100);
        uint256 listingId = nftMarket.list(address(myNFT), 100, 1);
        
    }

    function test_BuyNFTSuccess() public {
        vm.startPrank(user);
        myNFT.mintNFT(user, tokenURI);  //tokenID = 0
        myNFT.approve(address(nftMarket), 0);
        nftMarket.list(address(myNFT), 100, 0);
        vm.stopPrank();

        deal(address(paymentToken), address(this), 200);
        console.log(paymentToken.balanceOf(address(this)));
        paymentToken.approve(address(nftMarket), 150);

        vm.expectEmit(true, true, true, true);
        emit NFTSold(0, user, address(this), address(myNFT), 0, 100);
     
        nftMarket.buyNFT(0);

        assertEq(myNFT.ownerOf(0), address(this));
    }

    function test_BuySelfNFT() public {

        myNFT.mintNFT(address(this), tokenURI);  //tokenId = 0
        myNFT.approve(address(nftMarket), 0);
        nftMarket.list(address(myNFT), 100, 0);

        deal(address(paymentToken), address(this), 200);
        paymentToken.approve(address(nftMarket), 200);

        vm.expectRevert("NFTMarket: caller is the seller");
        nftMarket.buyNFT(0);

    }

    function test_BuySameNFTMultipleTimes() public {
        vm.startPrank(user);
        myNFT.mintNFT(user, tokenURI); //tokenId = 0
        myNFT.approve(address(nftMarket), 0);
        nftMarket.list(address(myNFT), 100, 0);
        vm.stopPrank();

        deal(address(paymentToken), address(this), 300);
        paymentToken.approve(address(nftMarket), 300);
        nftMarket.buyNFT(0);


        vm.expectRevert("NFTMarket: listing is not active");
        nftMarket.buyNFT(0);


    }

    function test_BuyNFTWithInsufficientTokens() public {
        vm.startPrank(user);
        myNFT.mintNFT(user, tokenURI);
        myNFT.approve(address(nftMarket), 0);
        nftMarket.list(address(myNFT), 100, 0);
        vm.stopPrank();

        //buy nft with insufficient tokens
        deal(address(paymentToken), address(this), 50);
        bytes memory data = abi.encode(0);
        
        vm.expectRevert();
        paymentToken.transferWithCallbackAndData(address(nftMarket), 50, data);


    }


       function test_BuyNFTWithOverpaidTokens() public {

        vm.startPrank(user);
        myNFT.mintNFT(user, tokenURI);
        myNFT.approve(address(nftMarket), 0);
        nftMarket.list(address(myNFT), 100, 0);
        vm.stopPrank();

        //buy nft with insufficient tokens
        deal(address(paymentToken), address(this), 200);
        bytes memory data = abi.encode(0);
        
        vm.expectRevert();
        paymentToken.transferWithCallbackAndData(address(nftMarket), 200, data);


    }

    function testFuzz_ListAndBuyNFT(uint256 price, address buyer) public {
        vm.assume(price >= 1 && price <= 10_000);
        vm.assume(buyer != address(0) && buyer != address(this));
        
        myNFT.mintNFT(address(this), tokenURI);
        myNFT.approve(address(nftMarket), 0);
        nftMarket.list(address(myNFT), price, 0);

        vm.startPrank(buyer);
        deal(address(paymentToken), buyer, price + 10);
        paymentToken.approve(address(nftMarket), price + 10);

        vm.expectEmit(true, true, true, true);
        emit NFTSold(0, address(this), buyer, address(myNFT), 0, price);
        nftMarket.buyNFT(0);


        vm.stopPrank();
    }


    // Invariant Testing
    // Run with `forge test`
    function invariant_marketAlwaysZeroBalance() public {
        assertEq(paymentToken.balanceOf(address(nftMarket)), 0, "Market contract should never hold payment tokens");
    }
}
