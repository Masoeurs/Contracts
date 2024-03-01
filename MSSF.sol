/**
 *Submitted for verification at BscScan.com on 2024-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BEP20Token is IBEP20 {
    address private _owner;
    address private _marketingWallet;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public liquidityFee = 0;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can call this function");
        _;
    }

    constructor() {
        _name = "Masoeurs Finance";
        _symbol = "MSSF";
        _decimals = 18;
        _owner = msg.sender;
        _marketingWallet = address(0x2D9a9340A1aDA465C1F3F3d80F9983e7954C7BA3);
        _totalSupply = 10000000 * 10 ** 18; // Initial total supply of 10,000,000 tokens
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function setMarketingWallet(address marketingWallet_) external onlyOwner {
        _marketingWallet = marketingWallet_;
    }

    function setLiquidityFee(uint256 fee) external onlyOwner {
        require(fee <= 100, "Liquidity fee percentage must be less than or equal to 100");
        liquidityFee = fee;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        uint256 liquidityAmount = amount * liquidityFee / 100;
        uint256 transferAmount = amount - liquidityAmount;

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[_marketingWallet] += liquidityAmount;

        emit Transfer(sender, recipient, transferAmount);
        emit Transfer(sender, _marketingWallet, liquidityAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}