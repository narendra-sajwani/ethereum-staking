// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract ETHStakingWithLiquidTokens is ERC20, ReentrancyGuard {
    mapping(address => uint256) public stakedBalance;
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor() ERC20("Liquid Staked ETH", "lsETH") {}

    function stake() external payable nonReentrant {
        require(msg.value > 0, "Must stake more than 0 ETH");

        stakedBalance[msg.sender] += msg.value;
        totalStaked += msg.value;

        // Mint liquid tokens equivalent to the staked amount
        _mint(msg.sender, msg.value);

        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0, "Must unstake more than 0 ETH");
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");
        require(balanceOf(msg.sender) >= amount, "Insufficient liquid tokens");

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        // Burn the equivalent amount of liquid tokens
        _burn(msg.sender, amount);

        // Transfer the unstaked ETH back to the user
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Unstaked(msg.sender, amount);
    }

    function getStakedBalance(address user) external view returns (uint256) {
        return stakedBalance[user];
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }

    // Allow the contract to receive ETH
    receive() external payable {}
}