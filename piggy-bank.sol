// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract PiggyBank {
    event Deposit(uint amount);
    event Withdraw(uint amount);

    address public immutable owner = msg.sender;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not the owner");
        _;
    }
    modifier sufficientBalance(uint _amount) {
        require(address(this).balance >= _amount, "Insufficient balance");
        _;
    }
    function deposit() external  payable{
        emit Deposit(msg.value);
    }

    function withdraw(uint _amount) external onlyOwner sufficientBalance(_amount){
        emit Withdraw(_amount);
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}
