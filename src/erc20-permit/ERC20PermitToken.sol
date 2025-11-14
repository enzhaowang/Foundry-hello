// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MyToken - ERC20 + EIP-2612 Permit
contract ERC20PermitToken is ERC20, ERC20Permit, Ownable {
    constructor(address initialOwner, uint256 initialSupply)
        ERC20("My Token", "MTK")
        ERC20Permit("My Token")
        Ownable(initialOwner)
    {
        _mint(initialOwner, initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }

    function permitAndTransferFrom(
        address owner,
        address to,
        uint256 value,
        uint256 deadline,
        uint8 v, bytes32 r, bytes32 s
    ) external {
        permit(owner, msg.sender, value, deadline, v, r, s);
        transferFrom(owner, to, value);
    }

    function currentNonce(address owner) external view returns (uint256) {
        return nonces(owner);
    }
}
