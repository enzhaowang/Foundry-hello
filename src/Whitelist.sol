//SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Whiltelist is Ownable, EIP712 {
    using ECDSA for bytes32;

    //====================
    // 方法1: Mapping白名单
    //====================
    
    mapping(address => bool) public mappingWhitelist;

    event MappingWhitelistAdded(address indexed account);
    event MappingWhitelistRemoved(address indexed account);

    /**
    * 添加地址到mapping白名单
    *
    */
    function addToMappingWhitelist(address account) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(!mappingWhitelist[account], "Already whitelisted");
        mappingWhitelist[account] = true;
        emit MappingWhitelistAdded(account);
    }

    /**
    * 批量添加地址到mapping
    *
    */
    function addBatchToMappingWhitelist(address[] calldata accounts) external onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            if (accounts[i] != address(0) && !mappingWhitelist[accounts[i]]) {
                mappingWhitelist[accounts[i]] = true;
                emit MappingWhitelistAdded(accounts[i]);
            }
        }
    }

    /**
    * 从白名单移除地址
    * 
    **/
    function removeFromMappingWhitelist(address account) external onlyOwner {
        require(account != address(0), "Invalid address");
        require(mappingWhitelist[account], "Not in the whitelist");
        mappingWhitelist[account] = false;
        emit MappingWhitelistRemoved(account);
    }

    /**
    * 判断account是否在白名单中
    **/
    function isInMappingWhitelist(address account) public view returns(bool) {
        require(account != address(0), "Invalid address");
        return mappingWhitelist[account];
    }


   //==========================
   // 方法2: EIP-712 签名验证白名单
   //==========================
    
    //签名者地址
    address public signer;

    //用户结构体
    struct WhitelistRequest {
        address user;
        uint256 nonce;
        uint256 expiry;
    }

    bytes32 public constant WHITE_TYPEHASH = keccak256("WhitelistRequest(address user,uint256 nonce,uint256 expiry)");

    //用于防止重放攻击的nonce
    mapping(address => uint256) public nonces;

    event SignerUpdated(address indexed newSigner);

    constructor() EIP712("Whitelist", "1") Ownable(msg.sender) {
        signer = msg.sender;
    }

    /**
    * set signer
    **/
    function setSigner(address newSigner) external onlyOwner {
        require(newSigner != address(0), "Invalid address");
        signer = newSigner;
        emit SignerUpdated(newSigner);
    }

    /**
    * 生成EIP-712哈希
    **/
    function hashWhitelistRequest(WhitelistRequest memory request) public view returns(bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(WHITE_TYPEHASH,
                request.user,
                request.nonce,
                request.expiry
                )
            )
        );
    }

    /**
    * 验证EIP-712签名白名单
    **/
    function verifyEIP712Whitelist(
        address user,
        uint256 nonce,
        uint256 expiry,
        bytes memory signature
    ) public view returns (bool) {
        //检查签名
        if (block.timestamp > expiry) {
            return false;
        }

        //检查nonce
        if (nonce != nonces[user]) {
            return false;
        }

        //verify signature
        WhitelistRequest memory request = WhitelistRequest({
            user: user,
            nonce: nonce,
            expiry: expiry
        });

        bytes32 digest = hashWhitelistRequest(request);
        address recovered = digest.recover(signature);
        return recovered == signer;

    }

    /**
    * claim with EIP712
    **/
    function claimWithEIP712(
        uint256 nonce,
        uint256 expiry,
        bytes memory signature
    ) external {
        require(verifyEIP712Whitelist(msg.sender, nonce, expiry, signature),
        "Invalid signature or not whitelisted"
        );

        //increase nonce in case multiple entries
        nonces[msg.sender]++;

        //mint NFT and claim rewards
    }


    //================================
    // 方法3: Merkle Tree白名单
    //================================
     bytes32 public merkleRoot;

     //record claimed addresses
     mapping(address => bool) public hasClaimed;

     event MerkleRootUpdated(bytes32 indexed newRoot);
     event Claimed(address indexed account);

     /**
     * set merkleRoot
     **/
     function setMerkleRoot(bytes32 newRoot) external onlyOwner {
        merkleRoot = newRoot;
        emit MerkleRootUpdated(newRoot);
     }

     /**
     * verify account
     **/
     function verifyMerkleProof(
        address account,
        bytes32[] calldata proof
     ) public view returns (bool) {
        bytes32 leaf = keccak256((abi.encodePacked(account)));
        return MerkleProof.verify(proof, merkleRoot, leaf);
     }

    /**
    * claim
    **/
    function claimWithMerkle(bytes32[] calldata proof) external {
        require(!hasClaimed[msg.sender], "Already claimed");

        require(verifyMerkleProof(msg.sender, proof), "Invalid prrof or not whitelisted");

        hasClaimed[msg.sender] = true;
        emit Claimed(msg.sender);

        //excute actions
        //mint NFT, claim rewards etc
    }


    //reset claimed account
    function resetClaimed(address account) external onlyOwner {
        hasClaimed[account] = false;
    }

    //get nonce
    function getNonce(address user) external view returns(uint256) {
        return nonces[user];
    }



}