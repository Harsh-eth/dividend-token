// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "underflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "division by zero");
        return a / b;
    }
}

contract Token {
    using SafeMath for uint256;

    uint256 public totalSupply;
    uint256 public decimals = 18;
    string public name = "Test token";
    string public symbol = "TEST";

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public pendingDividends;
    mapping(address => bool) private isHolder;
    address[] private holders;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount, address dest);
    event DividendRecorded(uint256 amount);
    event DividendWithdrawn(address indexed from, uint256 amount, address dest);

    function _addHolder(address addr) internal {
        if(!isHolder[addr] && balanceOf[addr] > 0) {
            isHolder[addr] = true;
            holders.push(addr);
        }
    }

    function _removeHolder(address addr) internal {
        if(isHolder[addr] && balanceOf[addr] == 0) {
            isHolder[addr] = false;
            for(uint i = 0; i < holders.length; i++) {
                if(holders[i] == addr) {
                    holders[i] = holders[holders.length - 1];
                    holders.pop();
                    break;
                }
            }
        }
    }

    function allowance(address owner, address spender) external view returns(uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) external returns(bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns(bool) {
        require(balanceOf[msg.sender] >= value, "insufficient balance");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        if(balanceOf[msg.sender] == 0) _removeHolder(msg.sender);
        if(balanceOf[to] > 0 && !isHolder[to]) _addHolder(to);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns(bool) {
        require(balanceOf[from] >= value, "insufficient balance");
        require(_allowances[from][msg.sender] >= value, "insufficient allowance");
        balanceOf[from] = balanceOf[from].sub(value);
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        if(balanceOf[from] == 0) _removeHolder(from);
        if(!isHolder[to] && balanceOf[to] > 0) _addHolder(to);
        emit Transfer(from, to, value);
        return true;
    }

    function mint() external payable {
        require(msg.value > 0, "send ETH to mint");
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value);
        totalSupply = totalSupply.add(msg.value);
        if(!isHolder[msg.sender]) {
            isHolder[msg.sender] = true;
            holders.push(msg.sender);
        }
        emit Minted(msg.sender, msg.value);
    }

    function burn(address payable dest) external {
        uint256 amount = balanceOf[msg.sender];
        require(amount > 0, "nothing to burn");
        totalSupply = totalSupply.sub(amount);
        balanceOf[msg.sender] = 0;
        _removeHolder(msg.sender);
        (bool ok,) = dest.call{value: amount}("");
        require(ok, "transfer failed");
        emit Burned(msg.sender, amount, dest);
    }

    function getNumTokenHolders() external view returns(uint256) {
        return holders.length;
    }

    function getTokenHolder(uint256 index) external view returns(address) {
        return holders[index - 1];
    }

    function recordDividend() external payable {
        require(msg.value > 0, "send ETH to record dividend");
        require(totalSupply > 0, "no holders");
        for(uint i = 0; i < holders.length; i++) {
            uint256 dividend = balanceOf[holders[i]].mul(msg.value).div(totalSupply);
            pendingDividends[holders[i]] = pendingDividends[holders[i]].add(dividend);
        }
        emit DividendRecorded(msg.value);
    }

    function getWithdrawableDividend(address payee) external view returns(uint256) {
        return pendingDividends[payee];
    }

    function withdrawDividend(address payable dest) external {
        uint256 amount = pendingDividends[msg.sender];
        require(amount > 0, "no dividends");
        pendingDividends[msg.sender] = 0;
        (bool ok,) = dest.call{value: amount}("");
        require(ok, "transfer failed");
        emit DividendWithdrawn(msg.sender, amount, dest);
    }
}
