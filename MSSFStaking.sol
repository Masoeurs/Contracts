/**
 *Submitted for verification at BscScan.com on 2024-02-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract MSSFStaking {
    using SafeMath for uint256;

    // Contract owner
    address public owner;

    // MSSF token
    IERC20 public MSSF;

    // vMSSF token
    IERC20 public vMSSF;

    // Staking start time
    mapping(address => uint256) public stakingTime;

    // Staked MSSF balances
    mapping(address => uint256) public stakedBalances;

    // Events
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);
    event TokensRefunded(address indexed user, uint256 amount);

    // APR rate (100%)
    uint256 public apr = 100;

    // Minimum staking time (60 days)
    uint256 public minStakingTime = 60 days;

    // Constructor
    constructor() {
        owner = msg.sender;
        MSSF = IERC20(0x85849af2A4cef3b9fCAE3bc0838FefCdd4530FB0);
        vMSSF = IERC20(0x00C7003Fb18dF5C6B258D67A00866640A74a50B6);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Set the address of the MSSF token
    function setMSSFAddress(address _MSSF) external onlyOwner {
        MSSF = IERC20(_MSSF);
    }

    // Set the address of the vMSSF token
    function setVMSSFAddress(address _vMSSF) external onlyOwner {
        vMSSF = IERC20(_vMSSF);
    }

    // Stake MSSF tokens
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        uint256 allowance = MSSF.allowance(msg.sender, address(this));
        require(allowance >= amount, "Allowance not enough");

        MSSF.transferFrom(msg.sender, address(this), amount);

        stakingTime[msg.sender] = block.timestamp;

        stakedBalances[msg.sender] = stakedBalances[msg.sender].add(amount);

        emit Staked(msg.sender, amount);
    }

    // Unstake MSSF tokens
    function unstake() external {
        require(block.timestamp >= stakingTime[msg.sender].add(minStakingTime), "Minimum staking time not reached");

        uint256 stakedAmount = stakedBalances[msg.sender];
        require(stakedAmount > 0, "No tokens staked");

        uint256 vMSSFToTransfer = calculateReward(msg.sender);

        stakedBalances[msg.sender] = 0;
        stakingTime[msg.sender] = 0;

        MSSF.transfer(msg.sender, stakedAmount);
        vMSSF.transfer(msg.sender, vMSSFToTransfer);

        emit Unstaked(msg.sender, stakedAmount);
        emit RewardClaimed(msg.sender, vMSSFToTransfer);
    }

    // Calculate the vMSSF rewards
    function calculateReward(address user) internal view returns (uint256) {
        uint256 stakingDuration = block.timestamp.sub(stakingTime[user]);
        uint256 reward = stakedBalances[user].mul(apr).mul(stakingDuration).div(365 days).div(100);
        return reward;
    }

    
    // Function to get user staking details
    function getUserStakingDetails(address user) external view returns (uint256 stakedAmount, uint256 reward, uint256 withdrawalAvailableDate) {
        stakedAmount = stakedBalances[user];
        reward = calculateReward(user);
        withdrawalAvailableDate = stakingTime[user].add(minStakingTime);
    }
}