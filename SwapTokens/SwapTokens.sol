// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev Contract for swapping tokenA for tokenB and vice versa with rate
 * that is set by the owner
 */
contract SwapTokens is Ownable {
    ERC20 public tokenA;
    ERC20 public tokenB;
    uint8 public rate;

    /**
     * @dev Sets the values for {tokenA}, {tokenB} and {rate}.
     *
     * All two of these values are mutable {tokenABalance}, {tokenBBalance}
     * and {changeRate} can modify them.
     */
    constructor(address _tokenA, address _tokenB, uint8 _rate) Ownable(msg.sender) {
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
        rate = _rate;
    }

    /**
     * @dev Sends token A from msg.sender to the contract, 
     * msg.sender receives token B from the contract.
     *
     * Requirements:
     * 
     * - `amount` should be greater than 0.
     * - `sender` should have a balance of token A at least `amount`
     * - `address(this)` must have allowance for ``sender``'s tokens A of at least `amount`.
     */
    function ASwapToB(uint amount) public {
        require(amount > 0, "Please enter valid amount");

        uint amountOfB = (amount * rate) / 100;

        require(tokenA.transferFrom(msg.sender,address(this), amount), "Transfer of token A failed");
        
        require(tokenB.transfer(msg.sender, amountOfB), "Transfer of token B failed");
    }
    /**
     * @dev Sends token B from msg.sender to the contract, 
     * msg.sender receives token A from the contract.
     *
     * Requirements:
     * 
     * - `amount` should be greater than 0.
     * - `sender` should have a balance of token B at least `amount`
     * - `address(this)` must have allowance for ``sender``'s tokens A of at least `amount`.
     */
    function BSwapToA(uint amount) public {
        require(amount > 0, "Please enter valid amount");

        uint amountOfB = (amount * 100) / rate;
        
        require(tokenB.transferFrom(msg.sender,address(this), amount), "Transfer of token B failed");
        
        require(tokenA.transfer(msg.sender, amountOfB), "Transfer of token A failed");
    }

    /**
     * @dev Changes the contract of tokenA
     *
     * Requirements:
     *
     * - Can only be called by the owner.
     * - _tokenA must be valid ERC20.
     */
    function changeTokenA(address _tokenA) public onlyOwner {
        tokenA = ERC20(_tokenA);
    }
    /**
     * @dev Changes the contract of tokenB
     *
     * Requirements:
     *
     * - Can only be called by the owner.
     * - _tokenB must be valid ERC20.
     */
    function changeTokenB(address _tokenB) public onlyOwner {
        tokenB = ERC20(_tokenB);
    }
    /**
     * @dev Changes the current swap rate
     *
     * Requirements:
     *
     * - Can only be called by the owner.
     */
    function changeRate(uint8 newRate) public onlyOwner {
        rate = newRate;
    }
    /**
     * @dev Returns the balance of tokenA of the contract
     */
    function tokenABalance() public view virtual returns (uint256) {
        return tokenA.balanceOf(address(this));
    }
    /**
     * @dev Returns the balance of tokenB of the contract
     */
    function tokenBBalance() public view virtual returns (uint256) {
        return tokenB.balanceOf(address(this));
    }
 }
